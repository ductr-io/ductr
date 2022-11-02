# frozen_string_literal: true

require "kiba"

module Ductr
  module ETL
    #
    # A runner based on kiba's streaming runner
    # @see Kiba's streaming runner source code to get details about its forwarded methods
    #
    class KibaRunner < Runner
      extend Forwardable
      def_delegators Kiba::StreamingRunner, :source_stream, :transform_stream, :process_rows, :close_destinations

      #
      # Calls kiba's streaming runner #process_rows and #close_destinations like Kiba::StreamingRunner#run
      #
      # @return [void]
      #
      def run
        process_rows(sources, transforms, destinations)
        close_destinations(destinations)
      end
    end
  end
end
