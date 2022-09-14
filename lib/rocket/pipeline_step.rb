# frozen_string_literal: true

require "forwardable"

module Rocket
  class PipelineStep
    extend Forwardable
    def_delegators :fiber, :resume, :alive?

    attr_reader :pipeline, :name, :jobs
    attr_accessor :left

    def initialize(pipeline, name)
      @pipeline = pipeline
      @name = name

      @done = false
      @jobs = []
      @left = []
    end

    def done?
      @done
    end

    def flush_jobs
      return if jobs.empty?

      Fiber.yield until Store.read_jobs(*jobs).all?(&:stopped?)
    end

    def fiber
      @fiber ||= Fiber.new do
        Fiber.yield until left.all?(&:done?)

        pipeline.send(name)
        flush_jobs

        @done = true
      end
    end
  end
end
