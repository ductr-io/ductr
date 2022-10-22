# frozen_string_literal: true

module Rocket
  module ETL
    #
    # Contains anything to "parse" ETL jobs annotations.
    # #parse_annotations handles ETL controls.
    # #parse_ractor_annotations handles send_to directives.
    #
    module Parser
      #
      # Handles send_to directives, used to do the plumbing between controls.
      # Used for the ractor runner initialization.
      #
      # @return [Array<Source, Transform, Destination, Hash{Symbol => Symbol, Array<Symbol>}>]
      #   The controls with a hash representing control plumbing
      #
      def parse_ractor_annotations
        pipes = find_method(:send_to) do |method|
          { from: method.name, to: method.find_annotation(:send_to).params }
        end

        [*parse_annotations, pipes]
      end

      #
      # Handles sources, transforms and destinations controls.
      # Used for the kiba's streaming runner initialization.
      #
      # @return [Array<Source, Transform, Destination>] The job's controls
      #
      def parse_annotations
        sources = init_adapter_controls(:source)
        transforms = init_transform_controls(:transform, :lookup)
        destinations = init_adapter_controls(:destination)

        [sources, transforms, destinations]
      end

      private

      #
      # Finds the method(s) associated to the given annotation names in the job class.
      #
      # @param [Array<Symbol>] *annotation_names The annotation names of the searched methods
      # @yield [method] The block to execute on each founded methods
      # @yieldparam [method] A job's method
      #
      # @return [Array] Returns mapped array containing the block's returned value
      #
      def find_method(*annotation_names, &)
        self.class.annotated_methods(*annotation_names).map(&)
      end

      #
      # Initializes adapter controls for the given type.
      #
      # @param [Symbol] control_type The adapter control type, one of :source or :destination
      #
      # @return [Array<Source, Destination>] The initialized adapter controls
      #
      def init_adapter_controls(control_type)
        find_method(control_type) do |method|
          adapter_control(method)
        end
      end

      #
      # Initializes transform controls for the given types.
      #
      # @param [Array<Symbol>] *control_types The transform control types, :transform and/or :lookup
      #
      # @return [Array<Transform>] The initialized transform controls
      #
      def init_transform_controls(*control_types)
        find_method(*control_types) do |method|
          next adapter_control(method) if method.annotation_exist?(:lookup)

          transform_control(method)
        end
      end

      #
      # Initializes an adapter control (source, lookup or destination).
      #
      # @param [Annotable::Method] annotated_method The control's method
      #
      # @return [Control] The adapter control instance
      #
      def adapter_control(annotated_method)
        annotation = annotated_method.find_annotation(:source, :destination, :lookup)
        adapter_name, control_type = annotation.params
        adapter = Rocket.config.adapter(adapter_name)

        control_class = adapter.class.send("#{annotation.name}_registry").find(control_type)
        params = [self, annotated_method.name, adapter_name]

        control_class.new(*params, **annotation.options)
      end

      #
      # Initializes a transform control.
      #
      # @param [Annotable::Method] annotated_method The transform's method
      #
      # @return [Transform] The transform control instance
      #
      def transform_control(annotated_method)
        annotation = annotated_method.find_annotation(:transform)
        transform_class = annotation.params.first || Transform
        params = [self, annotated_method.name]

        transform_class.new(*params, **annotation.options)
      end
    end
  end
end
