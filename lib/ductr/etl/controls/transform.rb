# frozen_string_literal: true

module Ductr
  module ETL
    #
    # Base class for implementing transforms.
    #
    class Transform < Control
      #
      # Calls the control method and passes the row.
      #
      # @param [Object] row The row to process
      #
      # @return [void]
      #
      def process(row)
        call_method(row)
      end

      #
      # Called when the last row is reached.
      #
      # @return [void]
      #
      def close; end
    end
  end
end
