# frozen_string_literal: true

module Rocket
  module ETL
    class BufferedDestination < Destination
      def buffer_size
        @options[:buffer_size]
      end

      def write(row)
        @buffer ||= []

        @buffer.push row
        flush_buffer if @buffer.size == buffer_size
      end

      def close
        flush_buffer unless @buffer.empty?
      end

      def flush_buffer(&)
        on_flush(@buffer)
        @buffer = []
      end
    end
  end
end
