# frozen_string_literal: true

module Rocket
  module Store
    #
    # Job's level store interactions.
    #
    module JobStore
      # @return [String] The job key prefix
      JOB_KEY_PREFIX = "rocket:job"
      # @return [String] The job registry key
      JOB_REGISTRY_KEY = "rocket:job_registry"

      #
      # Get all known job instances.
      #
      # @return [Array<Job>] The job instances
      #
      def all_jobs
        all(JOB_REGISTRY_KEY, JOB_KEY_PREFIX)
      end

      #
      # Read all given jobs.
      #
      # @param [Array<Job>] *jobs The jobs to read
      #
      # @return [Array<Job>] The read jobs
      #
      def read_jobs(*jobs)
        read(JOB_KEY_PREFIX, *jobs)
      end

      #
      # Update the given job.
      #
      # @param [Job] job The job to update in the store
      #
      # @return [void]
      #
      def write_job(job)
        write(JOB_KEY_PREFIX, job)
      end

      #
      # Add the given job to the store's job registry. This method is NOT thread-safe.
      #
      # @param [Job] job The job to register
      #
      # @return [void]
      #
      def register_job(job)
        register(JOB_REGISTRY_KEY, job)
      end
    end
  end
end
