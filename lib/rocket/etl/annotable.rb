# frozen_string_literal: true

module Rocket
  module ETL
    module Annotable
      def annotable(*annotation_names)
        annotation_names.each do |name|
          define_singleton_method(name) do |*params, **options|
            current_annotations.push Annotation.new(name, params, options).freeze
          end
        end
      end

      def annotated_methods(*names)
        @annotated_methods ||= []

        return @annotated_methods if @annotated_methods.empty?
        return @annotated_methods if names.empty?

        @annotated_methods.select do |method|
          annotation_found = false

          names.each do |name|
            annotation_found = method.annotation_exist?(name)
            break if annotation_found
          end

          annotation_found
        end
      end

      def annotated_method_exist?(name)
        !annotated_methods.find { |am| am.name == name }.nil?
      end

      private

      # callback called by ruby when a method is added into the class/module
      def method_added(name)
        super
        return if current_annotations.empty?

        remove_annotated_method(name) if annotated_method_exist?(name)
        @annotated_methods.push Method.new(name, *current_annotations)

        reset_current_annotations
      end

      def remove_annotated_method(name)
        @annotated_methods.reject! do |annotated_method|
          annotated_method.name == name
        end
      end

      def current_annotations
        @current_annotations ||= []
      end

      def reset_current_annotations
        @current_annotations = []
      end
    end
  end
end
