# frozen_string_literal: true

require "forwardable"
require "kiba"

module Rocket
  module ETL
    class KibaRunner < Runner
      extend Forwardable
      def_delegators Kiba::StreamingRunner, :source_stream, :transform_stream, :process_rows, :close_destinations

      def run
        process_rows(sources, transforms, destinations)
        close_destinations(destinations)
      end
    end
  end
end
