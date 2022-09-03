# frozen_string_literal: true

require "set"

module Rocket
  #
  # Store related methods for internal usage.
  #
  module StoreHelper
    class << self
      # @return [Integer] The cache expiration of job's status, default to one day
      EXPIRATION_INTERVAL = 86_400
      # @return [String] The job key prefix
      JOB_KEY_PREFIX = "rocket:job"
      # @return [String] The job registry key
      JOB_REGISTRY_KEY = "rocket:job_registry"

      #
      # Add the given job to the store's job registry. This method is NOT thread-safe.
      #
      # @param [Job] job The job to register
      #
      # @return [void]
      #
      def track_job(job)
        job_ids = Rocket.store.read(JOB_REGISTRY_KEY) || Set.new
        job_ids.add(job.job_id)
        Rocket.store.write(JOB_REGISTRY_KEY, job_ids, expires_in: EXPIRATION_INTERVAL)
      end

      #
      # Update the given job in the store.
      #
      # @param [Job] job The job to update in the store
      #
      # @return [void]
      #
      def update_job(job)
        Rocket.store.write("#{JOB_KEY_PREFIX}:#{job.job_id}", job, expires_in: EXPIRATION_INTERVAL)
      end

      #
      # Get all known job instances.
      #
      # @return [Array<Job>] The job instances
      #
      def fetch_jobs
        job_ids = Rocket.store.read(JOB_REGISTRY_KEY)
        return [] unless job_ids

        job_ids.to_a.map do |job_id|
          Rocket.store.read("#{JOB_KEY_PREFIX}:#{job_id}")
        end
      end

      #
      # Determines whether all tracked jobs have either a completed or failed status.
      #
      # @return [Boolean] `true` when all jobs are done
      #
      def all_jobs_done?
        fetch_jobs.all? do |job|
          %i[completed failed].include? job.status
        end
      end
    end
  end
end
