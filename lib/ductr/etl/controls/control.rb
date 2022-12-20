# frozen_string_literal: true

module Ductr
  module ETL
    #
    # Base class for all types of ETL control.
    #
    class Control
      extend Forwardable

      class << self
        # @return [Symbol] The control type, written when registering the control into its adapter
        attr_accessor :type
      end

      #
      # @!method call_method
      #   Invokes the job's method linked to the control.
      #   @return [Object] Something returned by the method, e.g. a query, a file, a row, ...
      #
      def_delegator :@job_method, :call, :call_method

      # @return [Symbol] The method to be called by the control
      attr_reader :job_method

      # @return [Hash] The configuration hash of the control's adapter
      attr_reader :options

      # @return [Adapter] The control's adapter
      attr_reader :adapter

      #
      # Creates a new control based on the job instance and the configured adapter.
      #
      # @param [Method] job_method The job's method to be called by the control
      # @param [Adapter] adapter The configured adapter
      # @param [Hash] **options The configuration hash of the control's adapter
      #
      def initialize(job_method, adapter = nil, **options)
        @job_method = job_method
        @adapter = adapter
        @options = options
      end
    end
  end
end
