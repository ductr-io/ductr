# frozen_string_literal: true

module Ductr
  module SQLite
    #
    # A lookup control that execute the query for a bunch of rows and merge them with the buffer's rows.
    #
    class MatchLookup < Ductr::ETL::BufferedTransform
      #
      # The looked up row key to match.
      #
      # @return [Symbol] The column name
      #
      def from_key
        @options[:merge].first
      end

      #
      # The buffer row key to match.
      #
      # @return [Symbol] The column name
      #
      def to_key
        @options[:merge].last
      end

      #
      # Opens the database if needed, calls the job's method and merges
      # the looked up rows with corresponding buffer rows.
      #
      # @yield [row] The each block
      # @yieldparam [Hash<Symbol, Object>] row The merged row
      #
      # @return [void]
      #
      def on_flush(&)
        call_method(adapter.db, buffer_keys).each do |row|
          match = buffer_find(row)
          next yield(row) unless match

          yield(row.merge match)
        end
      end

      private

      #
      # Find the corresponding row into the buffer.
      #
      # @param [Hash<Symbol, Object>] row The looked up row
      #
      # @return [Hash<Symbol, Object>, nil] the matching row if exists
      #
      def buffer_find(row)
        buffer.find { |r| r[from_key] == row[to_key] }
      end

      #
      # Maps the buffer keys into an array.
      #
      # @return [Array<Integer, String>] The keys array
      #
      def buffer_keys
        buffer.map { |row| row[from_key] }
      end
    end
  end
end
