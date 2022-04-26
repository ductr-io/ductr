# frozen_string_literal: true

module Rocket
  #
  # Base adapter class, your adapter should inherit of this class.
  #
  class Adapter
    class << self
      def source_registry
        @source_registry ||= ControlRegistry.new
      end

      def lookup_registry
        @lookup_registry ||= ControlRegistry.new
      end

      def destination_registry
        @destination_registry ||= ControlRegistry.new
      end
    end

    # @return [Symbol] the adapter instance name
    attr_reader :name

    #
    # Creates a new adapter instance.
    #
    # @param name [Symbol] The adapter instance name, mandatory, must be unique
    #
    def initialize(name)
      @name = name
    end

    #
    # Opens the adapter before using it e.g. open connection, authenticate to http endpoint, open file...
    # All implementations must ensure that #close! is called after the block execution.
    #
    # @yield a block to execute when the adapter is opened
    # @return [void]
    #
    def open(&)
      raise NotImplementedError, "An adapter must implement the #open! method"
    end

    #
    # Closes the adapter when finished e.g. close connection, drop http session, close file...
    #
    # @return [void]
    #
    def close!
      raise NotImplementedError, "An adapter must implement the #close! method"
    end
  end
end
