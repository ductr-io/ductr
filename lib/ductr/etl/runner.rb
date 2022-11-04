# frozen_string_literal: true

module Ductr
  module ETL
    #
    # The base class for all runners
    #
    class Runner
      # @return [Array<Source>] The runner source controls
      attr_accessor :sources

      # @return [Array<Transform>] The runner transform controls
      attr_accessor :transforms

      # @return [Array<Destination>] The runner destination controls
      attr_accessor :destinations

      #
      # Creates the runner instance.
      #
      # @param [Array<Source>] sources The job's source controls
      # @param [Array<Transform>] transforms The job's transform controls
      # @param [Array<Destination>] destinations The job's destination controls
      #
      def initialize(sources = [], transforms = [], destinations = [])
        @sources = sources
        @transforms = transforms
        @destinations = destinations
      end
    end
  end
end
