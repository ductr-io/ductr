# frozen_string_literal: true

module Rocket
  module Store
    #
    # Convert pipelines and steps into active job serializable structs.
    #
    module PipelineSerializer
      include JobSerializer

      #
      # @!parse
      #   #
      #   # The pipeline representation as a struct.
      #   #
      #   # @!attribute [r] job_id
      #   #   @return [String] The active job's job id
      #   #
      #   # @!attribute [r] status
      #   #   @return [Symbol] The pipeline job status
      #   #
      #   # @!attribute [r] error
      #   #   @return [Exception, nil] The pipeline job error if any
      #   #
      #   # @!attribute [r] steps
      #   #   @return [Array<SerializedPipelineStep>] The pipeline steps as struct
      #   #
      #   class SerializedPipeline < Struct
      #     #
      #     # @param [String] job_id Pipeline job id
      #     # @param [Symbol] status Pipeline status
      #     # @param [Exception, nil] error Pipeline error
      #     # @param [Array<SerializedPipelineStep>] steps Pipeline steps as struct
      #     #
      #     def initialize(job_id, status, error, steps)
      #       @job_id = job_id
      #       @status = status
      #       @error = error
      #       @steps = steps
      #     end
      #   end
      #
      SerializedPipeline = Struct.new(:job_id, :status, :error, :steps) do
        #
        # Determines whether the pipeline has a `completed` or `failed` status.
        #
        # @return [Boolean] True when the status is `completed` or `failed`
        #
        def stopped?
          %i[completed failed].include? status
        end
      end

      #
      # @!parse
      #   #
      #   # The pipeline step representation as a struct.
      #   #
      #   # @!attribute [r] jobs
      #   #   @return [Array<Job>] The step's jobs
      #   #
      #   # @!attribute [r] done
      #   #   @return [Boolean] The step's fiber state
      #   #
      #   class SerializedPipelineStep < Struct
      #     #
      #     # @param [Array<Job>] jobs The step's jobs
      #     # @param [Boolean] done The step's fiber state
      #     #
      #     def initialize(jobs, done)
      #       @jobs = jobs
      #       @done = done
      #     end
      #   end
      #
      SerializedPipelineStep = Struct.new(:jobs, :done) do
        #
        # Check if the step is done.
        #
        # @return [Boolean] True if the step is done
        #
        def done?
          done
        end
      end

      #
      # Convert the given pipeline and its steps into
      # `SerializedPipeline` and `SerializedPipelineStep` structs.
      #
      # @param [Pipeline] pipeline The pipeline to serialize
      #
      # @return [SerializedPipeline] The pipeline converted into struct
      #
      def serialize_pipeline(pipeline)
        serialized_steps = pipeline.runner.steps.map do |step|
          jobs = step.jobs.map { |j| serialize_job(j) }

          SerializedPipelineStep.new(jobs, step.done?)
        end

        SerializedPipeline.new(pipeline.job_id, pipeline.status, pipeline.error, serialized_steps)
      end
    end
  end
end
