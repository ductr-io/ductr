# frozen_string_literal: true

module Rocket
  #
  # The registry pattern to store controls.
  #
  class ControlRegistry
    #
    # Initialize the registry as an empty array
    #
    def initialize
      @controls = []
    end

    #
    # Allow to add a control class into the registry
    #
    # @param control [Class<Control>] The control to add in the registry
    # @param as: [Symbol] The control type
    #
    # @return [void]
    #
    def add(control, as:) # rubocop:disable Naming/MethodParameterName
      control.type = as
      @controls.push control
    end

    #
    # Find an control instance based on its type
    #
    # @param type [Symbol] The control type
    #
    # @raise [ControlNotFoundError] If no control match the given type
    # @return [Control] The found control
    #
    def find_by_type(type)
      error = -> { raise ControlNotFoundError, "The control of type \"#{type}\" does not exist" }

      @controls.find(error) do |control|
        control.type == type
      end
    end
  end
end
