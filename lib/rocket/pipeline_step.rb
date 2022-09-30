# frozen_string_literal: true

module Rocket
  #
  # Representation of a pipeline's step.
  # Hold a fiber to execute steps concurrently.
  #
  class PipelineStep
    extend Forwardable

    #
    # @!method resume
    #   Resumes the step's fiber.
    #   @return [void]
    # @!method alive?
    #   Check if the step's fiber is running.
    #   @return [Boolean] True if step's fiber is running
    #
    def_delegators :fiber, :resume, :alive?

    # @return [Pipeline] The step's pipeline
    attr_reader :pipeline
    # @return [Symbol] The step's name
    attr_reader :name
    # @return [Array<Job>] The step's queued jobs
    attr_reader :jobs

    # @return [PipelineStep] The previous step
    attr_accessor :left

    #
    # Creates a step for the given pipeline.
    #
    # @param [Pipeline] pipeline The pipeline containing step's method
    # @param [Symbol] The name of the pipeline's step method
    #
    def initialize(pipeline, name)
      @pipeline = pipeline
      @name = name

      @jobs = []
      @left = []
    end

    #
    # Track, registers and enqueues the given job.
    #
    # @param [Job] job The job to enqueue
    #
    # @return [void]
    #
    def enqueue_job(job)
      jobs.push(job)
      Store.register_job(job)
      job.enqueue
    end

    #
    # Check if the step is done.
    #
    # @return [Boolean] True if the step is done
    #
    def done?
      !fiber.alive?
    end

    #
    # Waits until all step's jobs are stopped.
    #
    # @return [void]
    #
    def flush_jobs
      return if jobs.empty?

      Fiber.yield until Store.read_jobs(*jobs).all?(&:stopped?)
    end

    #
    # The step's fiber instance, invokes the pipeline's step method.
    #
    # @return [Fiber] The step's fiber
    #
    def fiber
      @fiber ||= Fiber.new do
        Fiber.yield until left.all?(&:done?)

        pipeline.send(name)
        flush_jobs
      end
    end
  end
end
