# frozen_string_literal: true

module Rocket
  module ETL
    module Annotable
      class Method
        attr_reader :name, :annotations

        def initialize(name, *annotations)
          @name = name.freeze
          @annotations = annotations
        end

        def annotation_exist?(name)
          !annotations.find { |a| a.name == name }.nil?
        end

        def select_annotations(*names)
          annotations.select do |a|
            names.include? a.name
          end
        end
      end
    end
  end
end
