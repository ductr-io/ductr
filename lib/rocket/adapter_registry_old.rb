# frozen_string_literal: true

module Rocket
  #
  # The registry pattern to store adapter instances.
  #
  class AdapterRegistry
    class AdapterNotFoundError < StandardError; end

    #
    # Initialize the registry as an empty array
    #
    def initialize
      @adapters = []
    end

    #
    # Allow to add one adapter class with its name and config into the registry
    #
    # @param adapter_class [Class] The adapters to add in the registry
    # @param adapter_name [Symbol] The adapter name
    # @param **adapter_config [Hash] The adapter configuration
    #
    # @return [void]
    #
    def add(adapter_class, adapter_name, **adapter_config)
      @adapters.push [adapter_class, adapter_name, adapter_config]
    end

    #
    # Find an adapter based on its name and return a new instance of it.
    #
    # @param name [Symbol] The adapter name
    #
    # @raise [AdapterNotFoundError] If no adapter matches the given name
    # @return [Adapter] A new instance of the matching adapter
    #
    def find_new(name)
      not_found_error = -> { raise AdapterNotFoundError, "The adapter named \"#{name}\" does not exist" }

      adapter_class, adapter_name, adapter_config = *@adapters.find(not_found_error) do |entry|
        entry[1] == name
      end

      adapter_class.new(adapter_name, **adapter_config)
    end
  end
end
