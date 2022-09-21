# frozen_string_literal: true

module Rocket
  module Store
    #
    # Convert jobs into active job serializable structs.
    #
    module JobSerializer
      #
      # @!parse
      #   #
      #   # The job representation as a struct.
      #   #
      #   # @!attribute [r] job_id
      #   #   @return [String] The active job's job id
      #   #
      #   # @!attribute [r] status
      #   #   @return [Symbol] The job's status
      #   #
      #   class SerializedPipeline < Struct
      #     #
      #     # @param [String] job_id Active job's job id
      #     # @param [Symbol] status Job's status
      #     #
      #     def initialize(job_id, status)
      #       @job_id = job_id
      #       @status = status
      #     end
      #   end
      #
      SerializedJob = Struct.new(:job_id, :status) do
        #
        # Determines whether the job has a `completed` or `failed` status.
        #
        # @return [Boolean] True when the status is `completed` or `failed`
        #
        def stopped?
          %i[completed failed].include? status
        end
      end

      #
      # Convert the given job into a `SerializedJob` struct.
      #
      # @param [Job] job The job to serialize
      #
      # @return [SerializedJob] The job converted into struct
      #
      def serialize_job(job)
        SerializedJob.new(job.job_id, job.status)
      end
    end
  end
end
