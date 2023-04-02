# frozen_string_literal: true

module Ductr
  module Sequel
    #
    # A destination control that accumulates rows in a buffer to write them by batch.
    #
    class BufferedDestination < Ductr::ETL::BufferedDestination
      #
      # Open the database if needed and call the job's method to run the query.
      #
      # @return [void]
      #
      def on_flush
        call_method(adapter.db, buffer)
      end
    end
  end
end
