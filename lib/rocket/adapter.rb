# frozen_string_literal: true

module Rocket
  #
  # Base adapter class, your adapter should inherit of this class.
  #
  class Adapter
    class << self
      #
      # All the sources declared pour this adapter goes here.
      #
      # @return [ControlRegistry] The registry instance
      #
      def source_registry
        @source_registry ||= ControlRegistry.new
      end

      #
      # All the lookups declared pour this adapter goes here.
      #
      # @return [ControlRegistry] The registry instance
      #
      def lookup_registry
        @lookup_registry ||= ControlRegistry.new
      end

      #
      # All the destinations declared pour this adapter goes here.
      #
      # @return [ControlRegistry] The registry instance
      #
      def destination_registry
        @destination_registry ||= ControlRegistry.new
      end

      #
      # Make the registries ractor shareable, which freezes them.
      #
      # @return [void]
      #
      def make_shareable
        Ractor.make_shareable @source_registry
        Ractor.make_shareable @lookup_registry
        Ractor.make_shareable @destination_registry
      end
    end

    # @return [Symbol] the adapter instance name
    attr_reader :name

    # @return [Hash<Symbol, Object>] the adapter configuration hash
    attr_reader :config

    #
    # Creates a new adapter instance.
    #
    # @param [Symbol] name The adapter instance name, mandatory, must be unique
    # @param [Hash<Symbol, Object>] **config The adapter configuration hash
    #
    def initialize(name, **config)
      @name = name
      @config = config
    end

    #
    # Allow use of adapter with block syntax, automatically closes on block exit.
    #
    # @yield a block to execute when the adapter is opened
    # @return [void]
    #
    def open(&)
      yield(open!)
    ensure
      close!
    end

    #
    # Opens the adapter before using it e.g. open connection, authenticate to http endpoint, open file...
    # This method may return something, as a connection object.
    #
    # @return [void]
    #
    def open!
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
