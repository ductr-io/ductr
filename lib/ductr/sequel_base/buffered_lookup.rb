# frozen_string_literal: true

module Ductr
  module SequelBase
    #
    # A lookup control that execute the query for a bunch of rows.
    #
    class BufferedLookup < Ductr::ETL::BufferedTransform
      #
      # Opens the database if needed, calls the job's method and pass the each block to it.
      #
      # @yield The each block
      #
      # @return [void]
      #
      def on_flush(&)
        call_method(adapter.db, buffer, &)
      end
    end
  end
end
