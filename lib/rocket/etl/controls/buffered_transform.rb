# frozen_string_literal: true

module Rocket
  module ETL
    class BufferedTransform < Transform
      attr_reader :buffer

      def buffer_size
        @options[:buffer_size] || 10_000
      end

      def process(row, &)
        @buffer ||= []

        @buffer.push row
        flush_buffer(&) if @buffer.size == buffer_size

        # avoid returning a row, see
        # https://github.com/thbar/kiba/wiki/Implementing-ETL-transforms#generating-more-than-one-output-row-per-input-row-aka-yielding-transforms
        nil
      end

      def close(&)
        flush_buffer(&) unless @buffer.empty?
        super
      end

      def flush_buffer(&)
        on_flush(&)
        @buffer = []
      end
    end
  end
end
