# frozen_string_literal: true

module Ductr
  module ETL
    #
    # An runner based on Ractor.
    # This runner is EXPERIMENTAL, many database drivers & gems aren't compatible with ractor for now.
    #
    class RactorRunner < Runner
      #
      # Initializes the runner based on its controls and the plumbing between them.
      #
      # @param [Source] sources The job's sources
      # @param [Transform] transforms The job's transforms and lookups
      # @param [Destination] destinations The job's destinations
      # @param [Hash{Symbol => Symbol, Array<Symbol>}] pipes The controls plumbing
      #
      def initialize(sources, transforms, destinations, pipes)
        super(sources, transforms, destinations)
        @pipes = pipes

        @source_ractors, @transform_ractors, @destination_ractors = {}
        @pipe_ractors = []
      end

      #
      # Initialize controls and pipe ractors.
      #
      # @return [void]
      #
      def create_ractors!
        @source_ractors = create_control_ractors(@sources) { |s| source_ractor(s) }
        @transform_ractors = create_control_ractors(@transforms) { |t| transform_ractor(t) }
        @destination_ractors = create_control_ractors(@destinations) { |d| destination_ractor(d) }
        @pipe_ractors = create_pipes_ractors
      end

      #
      # Waits for the ractors to finish.
      #
      # @return [void]
      #
      def take_ractors!
        @destination_ractors.each_value(&:take)
      end

      #
      # Initializes ractors and waits for them to finish.
      #
      # @return [void]
      #
      def run
        create_ractors!
        take_ractors!
      end

      private

      #
      # Maps controls into a hash with job's method name as keys and control's ractors as values.
      #
      # @param [Array<Control>] controls The controls to map on the hash
      # @yield [control] The block in which the control ractor has to be initialized
      #
      # @return [Hash{Symbol => Ractor}] The mapped hash
      #
      def create_control_ractors(controls, &)
        controls.to_h do |control|
          [control.job_method, yield(control)]
        end
      end

      #
      # Initializes pipes ractors from the controls plumbing hash.
      #
      # @return [Array<Ractor>] The mapped pipes ractors
      #
      def create_pipes_ractors
        @pipes.map do |from_to|
          from, to = *from_to.values

          input = { **@source_ractors, **@transform_ractors }[from]
          outputs = to.map { |out| { **@transform_ractors, **@destination_ractors }[out] }

          pipe_ractor([input], outputs)
        end
      end

      #
      # Wraps the given source into a ractor.
      #
      # @param [Source] source The source to "ractorize"
      #
      # @return [Ractor] The ractor encapsulating the source
      #
      def source_ractor(source)
        Ractor.new(source) do |source|
          source.each do |row|
            Ractor.yield(row)
          end

          :end
        end
      end

      #
      # Wraps the given transform into a ractor.
      #
      # @param [Transform] transform The transform to "ractorize"
      #
      # @return [Ractor] The ractor encapsulating the transform
      #
      def transform_ractor(transform)
        Ractor.new(transform) do |transform|
          loop do
            row = transform.process(Ractor.receive) do |r|
              Ractor.yield(r)
            end

            Ractor.yield(row) if row
          end
          transform.close

          :end
        end
      end

      #
      # Wraps the given destination into a ractor.
      #
      # @param [Destination] destination The destination to "ractorize"
      #
      # @return [Ractor] the ractor encapsulating the destination
      #
      def destination_ractor(destination)
        Ractor.new(destination) do |destination|
          loop do
            destination.write(Ractor.receive)
          end
          destination.close
        end
      end

      #
      # Connects controls ractor to each other.
      #
      # @param [Array<Ractor>] pipe_inputs The ractors to connect to the the pipe's input.
      # @param [Array<Ractor>] pipe_outputs The ractors to connect to the the pipe's output.
      #
      # @return [Ractor] The pipe ractor
      #
      def pipe_ractor(pipe_inputs, pipe_outputs)
        Ractor.new(pipe_inputs, pipe_outputs) do |inputs, outputs|
          loop do
            break if inputs.empty?

            ractor, value = Ractor.select(*inputs)
            next inputs.delete(ractor) if value == :end

            outputs.each { |out| out.send(value) }
          end

          outputs.each(&:close_incoming)
        end
      end
    end
  end
end
