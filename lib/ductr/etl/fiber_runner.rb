# frozen_string_literal: true

module Ductr
  module ETL
    #
    # A runner built with fibers. Compared to KibaRunner,
    # this one allows to define how control are related to each other.
    # These definitions can be found in Runner#pipes method.
    #
    class FiberRunner < Runner
      #
      # Initializes fibers and waits for them to finish.
      #
      # @return [void]
      #
      def run
        create_fibers!
        @source_fibers.each_value(&:resume)
      end

      private

      #
      # Initializes control fibers and pipes them together.
      #
      # @return [void]
      #
      def create_fibers!
        @source_fibers = create_control_fibers(sources) { |s| FiberControl.new(s, type: :source) }
        @transform_fibers = create_control_fibers(transforms) { |t| FiberControl.new(t, type: :transform) }
        @destination_fibers = create_control_fibers(destinations) { |d| FiberControl.new(d, type: :destination) }

        apply_fibers_plumbing!
      end

      #
      # Pipes fiber controls together based on the control plumbing hash.
      #
      # @return [void]
      #
      def apply_fibers_plumbing!
        pipes.map do |from_to|
          from = from_to.keys.first
          to = from_to[from]

          input = { **@source_fibers, **@transform_fibers }[from]
          outputs = to.map { |out| { **@transform_fibers, **@destination_fibers }[out] }

          input.right = outputs
        end
      end

      #
      # Maps controls into a hash with job's method name as keys and control fibers as values.
      #
      # @param [Array<Control>] controls The controls to map on the hash
      # @yield [control] The block in which the control fiber has to be initialized
      #
      # @return [Hash{Symbol => FiberControl}] The mapped hash
      #
      def create_control_fibers(controls, &)
        controls.to_h do |control|
          [control.job_method.name, yield(control)]
        end
      end
    end
  end
end
