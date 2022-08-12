# frozen_string_literal: true

module Rocket
  module ETL
    #
    # Base class to implement buffered destinations.
    #
    class BufferedDestination < Destination
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
      # @param [Object] row The row to write
      #
      # @return [void]
      #
      def write(row)
        @buffer ||= []

        @buffer.push row
        flush_buffer if @buffer.size == buffer_size
      end

      #
      # Flushes the buffer, called when the last row is reached.
      #
      # @return [void]
      #
      def close
        flush_buffer unless @buffer.empty?
        super
      end

      #
      # Calls #on_flush and reset the buffer.
      #
      # @return [void]
      #
      def flush_buffer
        on_flush
        @buffer = []
      end

      #
      # Called each time the buffer have to be emptied.
      #
      # @return [void]
      #
      def on_flush
        raise NotImplementedError, "A buffered destination must implement the `#on_flush` method"
      end
    end
  end
end
