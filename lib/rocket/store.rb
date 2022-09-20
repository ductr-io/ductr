# frozen_string_literal: true

require "set"

module Rocket
  #
  # Store related methods for internal usage.
  #
  module Store
    extend JobStore
    extend PipelineStore

    class << self
      # @return [Integer] The cache expiration of job's status, default to one day
      EXPIRATION_INTERVAL = 86_400

      #
      # Get all known job instances for the given registry_key and job's key_prefix.
      #
      # @param [String] registry_key The registry key in which job keys will be read
      # @param [String] key_prefix The cache key prefix for the registry's job keys
      #
      # @return [Array<Job>] The job instances
      #
      def all(registry_key, key_prefix)
        job_ids = Rocket.store.read(registry_key)
        return [] unless job_ids

        keys = job_ids.map { |job_id| "#{key_prefix}:#{job_id}" }
        Rocket.store.read_multi(*keys).values
      end

      #
      # Read all given jobs in the given key_prefix.
      #
      # @param [String] key_prefix The cache key prefix for the job_id
      # @param [Array<Job>] *jobs The jobs to read
      #
      # @return [Array<Job>] The read jobs
      #
      def read(key_prefix, *jobs)
        keys = jobs.map { |job| "#{key_prefix}:#{job.job_id}" }
        Rocket.store.read_multi(*keys).values
      end

      #
      # Update the given job in the given key_prefix.
      #
      # @param [Job] job The job to update in the store
      #
      # @return [void]
      #
      def write(key_prefix, job)
        Rocket.store.write("#{key_prefix}:#{job.job_id}", job, expires_in: EXPIRATION_INTERVAL)
      end

      #
      # Add the given job to the store's job registry. This method is NOT thread-safe.
      #
      # @param [Job] job The job to register
      #
      # @return [void]
      #
      def register(registry_key, job)
        job_ids = Rocket.store.read(registry_key) || Set.new

        job_ids.add(job.job_id)
        Rocket.store.write(registry_key, job_ids, expires_in: EXPIRATION_INTERVAL)
      end

      #
      # Determines whether all tracked jobs have either a completed or failed status.
      #
      # @return [Boolean] `true` when all jobs are done
      #
      def all_done?
        [*all_jobs, *all_pipelines].all?(&:stopped?)
      end
    end
  end
end
