# frozen_string_literal: true

module Rocket
  class Pipeline < Job
    annotable :after
    queue_as :rocket_pipelines
    attr_reader :steps

    def initialize(...)
      super(...)

      @steps = step_names.map do |name|
        PipelineStep.new(self, name)
      end

      self.class.annotated_methods.each do |method|
        step_by(name: method.name).left = method.find_annotation(:after).params.map do |left_step_name|
          step_by(name: left_step_name)
        end
      end
    end

    def run
      until steps.empty?
        steps.each do |step|
          next steps.delete(step) unless step.alive?

          step.resume
        end

        sleep(0.1)
      end
    end

    def sync(job_class, *params)
      current_step.flush_jobs
      enqueue_job job_class.new(*params)
      current_step.flush_jobs
    end

    def async(job_class, *params)
      enqueue_job job_class.new(*params)
    end

    #
    # Writes the pipeline's status into the Rocket's store.
    #
    # @param [Symbol] status The status of the job
    #
    # @return [void]
    #
    def status=(status)
      @status = status
      Store.write_pipeline(self)
    end

    protected

    def enqueue_job(job)
      current_step.jobs.push(job)
      Store.register_job(job)
      job.enqueue
    end

    def current_step
      step_by fiber: Fiber.current
    end

    def step_names
      self.class.annotated_methods.flat_map do |method|
        [method.name, *method.find_annotation(:after).params]
      end.uniq
    end

    def step_by(**name_and_val)
      name, value = *name_and_val.to_a.first

      steps.find do |step|
        step.send(name) == value
      end
    end
  end
end
