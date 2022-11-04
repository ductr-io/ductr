# frozen_string_literal: true

module Ductr
  module Store
    #
    # Pipeline's level store interactions.
    #
    module PipelineStore
      include PipelineSerializer

      # @return [String] The pipeline key prefix
      PIPELINE_KEY_PREFIX = "ductr:pipeline"
      # @return [String] The pipeline registry key
      PIPELINE_REGISTRY_KEY = "ductr:pipeline_registry"

      #
      # Get all known pipeline instances.
      #
      # @return [Array<SerializedPipeline>] The pipeline instances
      #
      def all_pipelines
        all(PIPELINE_REGISTRY_KEY, PIPELINE_KEY_PREFIX)
      end

      #
      # Update the given pipeline.
      #
      # @param [Pipeline] pipeline The pipeline to update in the store
      #
      # @return [void]
      #
      def write_pipeline(pipeline)
        write(PIPELINE_KEY_PREFIX, serialize_pipeline(pipeline))
      end

      #
      # Add the given pipeline to the store's pipeline registry. This method is NOT thread-safe.
      #
      # @param [Pipeline] pipeline The job to register
      #
      # @return [void]
      #
      def register_pipeline(pipeline)
        register(PIPELINE_REGISTRY_KEY, pipeline)
      end
    end
  end
end
