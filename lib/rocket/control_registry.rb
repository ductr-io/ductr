# frozen_string_literal: true

module Rocket
  class ControlRegistry
    def initialize
      @controls = []
    end

    def add(control, as:) # rubocop:disable Naming/MethodParameterName
      control.type = as
      @controls.push control
    end

    def find_by_type(type)
      @controls.find do |control|
        control.type == type
      end
    end
  end
end
