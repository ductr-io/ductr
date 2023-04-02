# frozen_string_literal: true

module Ductr
  module SequelBase
    #
    # A lookup control that execute one query per row.
    #
    class BasicLookup < Ductr::ETL::Transform
      #
      # Calls the job's method to merge its result with the current row.
      #
      # @param [Hash<Symbol, Object>] row The current row, preferably a Hash
      #
      # @return [Hash<Symbol, Object>] The row merged with looked up row or the untouched row if nothing was found
      #
      def process(row)
        matching_row = call_method(adapter.db, row).first
        return row unless matching_row

        row.merge matching_row
      end
    end
  end
end
