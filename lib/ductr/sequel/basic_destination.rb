# frozen_string_literal: true

module Ductr
  module Sequel
    #
    # A destination control that write rows one by one.
    #
    class BasicDestination < Ductr::ETL::Destination
      #
      # Opens the database if needed and call the job's method to insert one row at time.
      #
      # @param [Hash<Symbol, Object>] row The row to insert, preferably a Hash
      #
      # @return [void]
      #
      def write(row)
        call_method(adapter.db, row)
      end
    end
  end
end
