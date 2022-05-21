# frozen_string_literal: true

module Rocket
  class KibaJob < Job
    annotable :source, :transform, :lookup, :destination

    def initialize
      super

      @runner = ETL::KibaRunner.new(*parse)
    end

    def run
      @runner.run
    end
  end
end
