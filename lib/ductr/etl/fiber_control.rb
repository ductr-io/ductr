# frozen_string_literal: true

module Ductr
  module ETL
    #
    # Glues ETL controls and the associated fibers together.
    #
    class FiberControl
      extend Forwardable

      #
      # @!method resume
      #   Resumes the control's fiber.
      #   @param [Object] row The row to pass to right fiber controls
      #   @return [void]
      def_delegators :fiber, :resume

      # @return [Array<FiberControl>] The next fiber controls
      attr_accessor :right
      # @return [Control] The ETL control instance
      attr_reader :control

      #
      # Creates a new fiber control with the given control and control type.
      #
      # @param [Control] control The ETL control to work with in the fiber
      # @param [Symbol] type The ETL control type, one of [:source, :transform, :destination]
      #
      def initialize(control, type:)
        @control = control
        @type = type

        @right = []
      end

      #
      # Memoizes the fiber to be associated with the ETL control based on its type.
      #
      # @return [Fiber] The fiber in charge of executing the control's logic
      #
      def fiber
        @fiber ||= send(@type)
      end

      private

      #
      # Creates the fiber to run ETL sources.
      #
      # @return [Fiber]
      #
      def source
        Fiber.new do
          control.each do |row|
            resume_right_fibers(row)
          end

          resume_right_fibers(:end)
        end
      end

      #
      # Creates the fiber to run ETL transforms.
      #
      # @return [Fiber]
      #
      def transform
        resume_control(Fiber.new do
          loop do
            row_in = Fiber.yield
            next close_transform if row_in == :end

            row_out = control.process(row_in) do |r|
              resume_right_fibers(r)
            end

            resume_right_fibers(row_out) if row_out
          end
        end)
      end

      #
      # Creates the fiber to run ETL Destinations.
      #
      # @return [Fiber]
      #
      def destination
        resume_control(Fiber.new do
          loop do
            row = Fiber.yield
            next control.close if row == :end

            control.write(row)
          end
        end)
      end

      #
      # Call #close on control, resume resulting rows then ends following fibers.
      #
      # @return [void]
      #
      def close_transform
        control.close do |row|
          resume_right_fibers(row)
        end
        resume_right_fibers(:end)
      end

      #
      # Resumes all fibers at the right of the current one.
      #
      # @param [Object] row The row to pass to the next fibers
      #
      # @return [void]
      #
      def resume_right_fibers(row)
        right.each do |fiber|
          fiber.resume(row)
        end
      end

      #
      # Resumes the given fiber and returns it.
      #
      # @param [Fiber] fiber The fiber to resume
      #
      # @return [Fiber] The resumed fiber
      #
      def resume_control(fiber)
        fiber.resume
        fiber
      end
    end
  end
end
