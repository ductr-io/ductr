# frozen_string_literal: true

module Rocket
  module ETL
    class BufferedTransform < Transform
      def buffer_size
        @options[:buffer_size]
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
      end

      def flush_buffer(&)
        on_flush(@buffer, &)
        @buffer = []
      end
    end
  end
end
