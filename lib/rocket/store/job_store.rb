# frozen_string_literal: true

module Rocket
  module Store
    module JobStore
      # @return [String] The job key prefix
      JOB_KEY_PREFIX = "rocket:job"
      # @return [String] The job registry key
      JOB_REGISTRY_KEY = "rocket:job_registry"

      def all_jobs
        all(JOB_REGISTRY_KEY, JOB_KEY_PREFIX)
      end

      def read_jobs(*jobs)
        read(JOB_KEY_PREFIX, *jobs)
      end

      def write_job(job)
        write(JOB_KEY_PREFIX, job)
      end

      def register_job(job)
        register(JOB_REGISTRY_KEY, job)
      end
    end
  end
end
