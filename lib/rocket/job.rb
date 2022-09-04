# frozen_string_literal: true

require "annotable"

module Rocket
  #
  # The base class for any job, you can use it directly if you don't need an ETL job.
  #
  class Job < ActiveJob::Base
    extend Annotable
    include ETL::Parser

    # @return [Exception] The occurred error if any
    attr_reader :error
    # @return [Symbol] The job's status, one of `:queued`, `:working`, `:completed` and `:failed`
    attr_reader :status

    queue_as :rocket_jobs

    before_enqueue { |job| job.update_status(:queued) }
    before_perform { |job| job.update_status(:working) }
    after_perform { |job| job.update_status(:completed) }

    rescue_from(Exception) do |e|
      @error = e
      update_status(:failed)

      raise e
    end

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
    # Writes the job's status into the Rocket's store.
    #
    # @param [Symbol] status The status of the job
    #
    # @return [void]
    #
    def update_status(status)
      @status = status
      StoreHelper.update_job(self)
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
