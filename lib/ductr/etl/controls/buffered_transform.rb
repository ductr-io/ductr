# frozen_string_literal: true

module Ductr
  module ETL
    #
    # Base class to implement buffered transforms.
    #
    class BufferedTransform < Transform
      # @return [Array] The row buffer
      attr_reader :buffer

      #
      # The buffer size option, default to 10_000.
      #
      # @return [Integer] The buffer size
      #
      def buffer_size
        @options[:buffer_size] || 10_000
      end

      #
      # Pushes the row inside the buffer or flushes it when full.
      #
      # @param [Object] row The row to process
      # @yield [row] The row yielder
      #
      # @return [nil] Returning nil to complies with kiba
      #
      def process(row, &)
        @buffer ||= []

        @buffer.push row
        flush_buffer(&) if @buffer.size == buffer_size

        # avoid returning a row, see
        # https://github.com/thbar/kiba/wiki/Implementing-ETL-transforms#generating-more-than-one-output-row-per-input-row-aka-yielding-transforms
        nil
      end

      #
      # Called when the last row is reached.
      #
      # @yield [row] The row yielder
      #
      # @return [void]
      #
      def close(&)
        flush_buffer(&) unless @buffer.empty?
        super
      end

      #
      # Calls #on_flush and reset the buffer.
      #
      # @yield [row] The row yielder
      #
      # @return [void]
      #
      def flush_buffer(&)
        on_flush(&)
        @buffer = []
      end

      #
      # Called each time the buffer have to be emptied.
      #
      # @yield [row] The row yielder
      #
      # @return [void]
      #
      def on_flush(&)
        raise NotImplementedError, "A buffered transform must implement the `#on_flush` method"
      end
    end
  end
end
