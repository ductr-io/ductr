# frozen_string_literal: true

module Rocket
  module Store
    module PipelineStore
      include PipelineSerializer

      # @return [String] The pipeline key prefix
      PIPELINE_KEY_PREFIX = "rocket:pipeline"
      # @return [String] The pipeline registry key
      PIPELINE_REGISTRY_KEY = "rocket:pipeline_registry"

      def all_pipelines
        all(PIPELINE_REGISTRY_KEY, PIPELINE_KEY_PREFIX)
      end

      def write_pipeline(pipeline)
        write(PIPELINE_KEY_PREFIX, serialize_pipeline(pipeline))
      end

      def register_pipeline(pipeline)
        register(PIPELINE_REGISTRY_KEY, pipeline)
      end
    end
  end
end
