# frozen_string_literal: true

module Rocket
  module ETL
    #
    # Base class for all types of control.
    #
    class Control
      class << self
        # @return [Symbol] The control type, setted when registering it into its adapter
        attr_accessor :type
      end

      # @return [Job] The job context
      attr_reader :context

      # @return [Symbol] The method to be called by the control
      attr_reader :job_method

      # @return [Symbol] The name of the configured adapter
      attr_reader :adapter_name

      # @return [Hash] The configuration hash of the control's adapter
      attr_reader :options

      #
      # Creates a new control based on the job instance and the configured adapter.
      #
      # @param [Job] context The control's job instance
      # @param [Symbol] job_method The job's method to be called by the control
      # @param [Symbol] adapter_name The name of the configured adapter
      # @param [Hash] **options The configuration hash of the control's adapter
      #
      def initialize(context, job_method, adapter_name = nil, **options)
        @context = context
        @job_method = job_method
        @adapter_name = adapter_name
        @options = options
      end

      #
      # @return [Adapter] The control's adapter
      #
      def adapter
        return nil unless @adapter_name

        @adapter ||= Rocket.config.adapter(@adapter_name)
      end

      private

      #
      # Invokes the job's method linked to the control.
      #
      # @param [Array] *params The params to pass to the job's method, optional
      # @yield The block to pas to the method, optional
      #
      # @return [Object] Something returned by the method, e.g. a query, a file, a row, ...
      #
      def call_method(*params, &)
        context.send(@job_method, *params, &)
      rescue StandardError
        adapter&.close!
        raise # re-raises the exact same error
      end
    end
  end
end
