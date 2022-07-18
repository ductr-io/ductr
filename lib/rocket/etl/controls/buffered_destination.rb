# frozen_string_literal: true

module Rocket
  module ETL
    class BufferedDestination < Destination
      attr_reader :buffer

      def buffer_size
        @options[:buffer_size] || 10_000
      end

      def write(row)
        @buffer ||= []

        @buffer.push row
        flush_buffer if @buffer.size == buffer_size
      end

      def close
        flush_buffer unless @buffer.empty?
        super
      end

      def flush_buffer(&)
        on_flush
        @buffer = []
      end
    end
  end
end
