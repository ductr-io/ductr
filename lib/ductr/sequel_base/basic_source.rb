# frozen_string_literal: true

module Ductr
  module SequelBase
    #
    # A source control that yields rows one by one.
    #
    class BasicSource < Ductr::ETL::Source
      #
      # Opens the database, calls the job's method and iterate over the query results.
      #
      # @yield The each block
      #
      # @return [void]
      #
      def each(&)
        call_method(adapter.db).each(&)
      end
    end
  end
end
