# frozen_string_literal: true

module Rocket
  module ETL
    #
    # Base class for implementing destinations.
    #
    class Destination < Control
      #
      # Writes the row into the destination.
      #
      # @param [Object] row The row to write
      #
      # @return [void]
      #
      def write(row)
        call_method(row)
      end

      #
      # Called when the last row is reached, closes the adapter.
      #
      # @return [void]
      #
      def close
        adapter.close!
      end
    end
  end
end
