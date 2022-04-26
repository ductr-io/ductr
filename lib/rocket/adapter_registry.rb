# frozen_string_literal: true

module Rocket
  #
  # The registry pattern to store adapter instances.
  #
  class AdapterRegistry
    #
    # Initialize the registry as an empty array
    #
    def initialize
      @adapters = {}
    end

    #
    # Allow to add one adapter class into the registry
    #
    # @param name [Symbol] The adapter names
    # @param adapter [Class] The adapter to add in the registry
    #
    # @return [void]
    #
    def add(adapter, as:) # rubocop:disable Naming/MethodParameterName
      @adapters[as.to_sym] = adapter
    end

    #
    # Find an adapter instance based on its type
    #
    # @param type [Symbol] The adapter type
    #
    # @raise [AdapterNotFoundError] If no adapter match the given type
    # @return [Adapter] The found adapter
    #
    def find_by_type(type)
      @adapters.fetch(type.to_sym) do
        raise AdapterNotFoundError, "The adapter of type \"#{type}\" does not exist"
      end
    end
  end
end
