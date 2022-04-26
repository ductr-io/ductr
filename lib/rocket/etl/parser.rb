# frozen_string_literal: true

module Rocket
  module ETL
    module Parser
      def parse
        sources = adapter_controls(:source)

        transforms = methods_by_type(:transform, :lookup).map do |method|
          next init_adapter_control(method) if method.annotation_exist?(:lookup)

          init_transform(method)
        end

        destinations = adapter_controls(:destination)

        [sources, transforms, destinations]
      end

      private

      def adapter_controls(control_type)
        methods_by_type(control_type).map do |method|
          init_adapter_control(method)
        end
      end

      def methods_by_type(*types)
        self.class.annotated_methods(*types)
      end

      def init_adapter_control(annotated_method)
        annotation = annotated_method.select_annotations(:source, :destination, :lookup).first
        adapter_name, control_type = annotation.params

        adapter = Rocket.config.adapter(adapter_name)
        control_class = adapter.class.send("#{annotation.name}_registry").find_by_type(control_type)

        control_class.new(self, annotated_method.name, adapter_name, **annotation.options)
      end

      def init_transform(annotated_method)
        annotation = annotated_method.select_annotations(:transform).first
        transform_class = annotation.params.first || Transform

        transform_class.new(self, annotated_method.name, **annotation.options)
      end
    end
  end
end
