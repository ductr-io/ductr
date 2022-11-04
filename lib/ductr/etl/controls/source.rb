# frozen_string_literal: true

module Ductr
  module ETL
    #
    # The base class for implementing sources.
    #
    class Source < Control
      #
      # Iterates over rows.
      #
      # @yield [row] The row yielder
      #
      # @return [void]
      #
      def each(&)
        call_method.each(&)
      end
    end
  end
end
