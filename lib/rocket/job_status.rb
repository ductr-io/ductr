# frozen_string_literal: true

require "annotable"

module Rocket
  #
  # This module contains the job's status tracking logic.
  # It relies on Active Job's callbacks to write status into the store.
  #
  module JobStatus
    class << self
      #
      # Registers the ActiveJob's `before_enqueue`, `before_perform` and `after_perform` callbacks
      # to write status in the Rocket's store.
      # Intercepts and re-raises job's exceptions to write the `:failed` status.
      #
      # @param [Class<Job>] job_class The job's class
      #
      # @return [void]
      #
      def included(job_class)
        job_class.before_enqueue { |job| job.status = :queued }
        job_class.before_perform { |job| job.status = :working }
        job_class.after_perform { |job| job.status = :completed }

        job_class.rescue_from(Exception) do |e|
          @error = e
          self.status = :failed

          raise e
        end
      end
    end

    #
    # Writes the job's status into the Rocket's store.
    #
    # @param [Symbol] status The status of the job
    #
    # @return [void]
    #
    def status=(status)
      @status = status
      Store.write_job(self)
    end

    #
    # Determines whether the job has a `completed` or `failed` status.
    #
    # @return [Boolean] True when the status is `completed` or `failed`
    #
    def stopped?
      %i[completed failed].include? status
    end
  end
end
