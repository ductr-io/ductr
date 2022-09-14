# frozen_string_literal: true

module Rocket
  module Store
    module PipelineSerializer
      SerializedPipeline = Struct.new(:job_id, :status, :steps) do
        def stopped?
          %i[completed failed].include? status
        end
      end

      SerializedPipelineStep = Struct.new(:jobs, :done) do
        def done?
          done
        end
      end

      def serialize_pipeline(pipeline)
        serialized_steps = pipeline.steps.map do |step|
          SerializedPipelineStep.new(step.jobs, step.done?)
        end
        SerializedPipeline.new(pipeline.job_id, pipeline.status, serialized_steps)
      end
    end
  end
end
