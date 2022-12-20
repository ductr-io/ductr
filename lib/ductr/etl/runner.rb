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

      # @return [Array<Hash{Symbol => Array<Symbol>}>] The controls plumbing hashes
      attr_accessor :pipes

      #
      # Creates the runner instance.
      #
      # @param [Array<Source>] sources The job's source controls
      # @param [Array<Transform>] transforms The job's transform controls
      # @param [Array<Destination>] destinations The job's destination controls
      # @param [Array<Hash{Symbol => Array<Symbol>}>] pipes The controls plumbing hashes
      #
      def initialize(sources, transforms, destinations, pipes = [])
        @sources = sources
        @transforms = transforms
        @destinations = destinations
        @pipes = pipes
      end
    end
  end
end
