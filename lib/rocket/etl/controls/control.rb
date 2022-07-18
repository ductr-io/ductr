# frozen_string_literal: true

module Rocket
  module ETL
    class Control
      class << self
        attr_accessor :type
      end

      def initialize(context, method_name, adapter_name = nil, **options)
        @context = context
        @method_name = method_name
        @adapter_name = adapter_name
        @options = options
      end

      def adapter
        return nil unless @adapter_name

        @adapter ||= Rocket.config.adapter(@adapter_name)
      end

      private

      def call_method(*params, &)
        SemanticLogger.tagged(method: @method_name) do
          @context.send(@method_name, *params, &)
        end
      rescue StandardError
        adapter&.close!
        raise # re-raises the exact same error
      end
    end
  end
end
