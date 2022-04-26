# frozen_string_literal: true

module Rocket
  module ETL
    class Runner
      attr_accessor :sources, :transforms, :destinations

      def initialize(sources = [], transforms = [], destinations = [])
        @sources = sources
        @transforms = transforms
        @destinations = destinations
      end
    end
  end
end
