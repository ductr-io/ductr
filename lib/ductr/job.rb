# frozen_string_literal: true

module Ductr
  #
  # The base class for any job, you can use it directly if you don't need an ETL job.
  #
  class Job < ActiveJob::Base
    extend Annotable
    extend Forwardable

    include JobStatus

    # @return [Exception] The occurred error if any
    attr_reader :error
    # @return [Symbol] The job's status, one of `:queued`, `:working`, `:completed` and `:failed`
    attr_reader :status

    queue_as :ductr_jobs

    #
    # The active job's perform method. DO NOT override it, implement the #run method instead.
    #
    # @return [void]
    #
    def perform(*_)
      run
    end

    #
    # The configured adapter instances.
    #
    # @param [Symbol] name The adapter name
    #
    # @return [Adapter] The adapter corresponding to the given name
    #
    def adapter(name)
      Ductr.config.adapter(name)
    end

    #
    # The job's logger instance.
    #
    # @return [Ductr::Log::Logger] The logger instance
    #
    def logger
      @logger ||= Ductr.config.logging.new(self.class)
    end

    #
    # The entry point of jobs.
    #
    # @return [void]
    #
    def run
      raise NotImplementedError, "A job must implement the `#run` method"
    end
  end
end
