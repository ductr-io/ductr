# frozen_string_literal: true

module Ductr
  class NotFoundInRegistryError < StandardError; end

  #
  # The registry pattern to store adapters, controls and triggers.
  #
  class Registry
    extend Forwardable

    #
    # @!method values
    #   Get all registered adapters, controls or triggers.
    #   @return [Array<Class<Adapter, ETL::Control, Trigger>>] The registered adapters, controls or triggers
    #
    def_delegators :@items, :values

    #
    # Initialize the registry as an empty hash with the given name.
    #
    # @param name [Symbol] The registry name, used in error message
    #
    def initialize(name)
      @name = name
      @items = {}
    end

    #
    # Allow to add one class into the registry.
    #
    # @param item [Class<Adapter, ETL::Control, Trigger>] The class to add in the registry
    # @param as: [Symbol] The adapter, control or trigger type
    #
    # @return [void]
    #
    def add(item, as:)
      @items[as.to_sym] = item
    end

    #
    # Find an adapter, control or trigger based on its type.
    #
    # @param type [Symbol] The adapter, control or trigger type
    #
    # @raise [NotFoundInRegistryError] If nothing matches the given type
    # @return [Class<Adapter, ETL::Control, Trigger>] The found adapter
    #
    def find(type)
      @items.fetch(type.to_sym) do
        raise NotFoundInRegistryError, "The #{@name} of type \"#{type}\" does not exist"
      end
    end
  end
end
