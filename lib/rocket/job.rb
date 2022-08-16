# frozen_string_literal: true

require "annotable"

module Rocket
  #
  # The base class for any job, you can use it directly if you don't need an ETL job.
  #
  class Job
    extend Annotable
    include ETL::Parser

    #
    # The active job's perform method. Do NOT override it, implement the #run method instead.
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
      Rocket.config.adapter(name)
    end

    #
    # The job's logger instance.
    #
    # @return [Rocket::Log::Logger] The logger instance
    #
    def logger
      Rocket.config.logging.new
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
