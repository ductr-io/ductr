# frozen_string_literal: true

module Rocket
  #
  # Base class for ETL job using the experimental ractor runner.
  # Usage example:
  #
  #   class MyRactorJob < Rocket::RactorJob
  #     source :ractor_first, :basic
  #     send_to :the_transform, :the_other_transform
  #     def the_source(db)
  #       # ...
  #     end
  #
  #     transform
  #     send_to :the_destination
  #     def the_transform(row)
  #       # ...
  #     end
  #
  #     destination :ractor_first, :basic
  #     def the_destination(row, db)
  #       # ...
  #     end
  #
  #     transform
  #     send_to :the_other_destination
  #     def the_other_transform(row)
  #       # ...
  #     end
  #
  #     destination :ractor_second, :basic
  #     def the_other_destination(row, db)
  #       # ...
  #     end
  #   end
  #
  class RactorJob < Job
    annotable :source, :transform, :lookup, :destination, :send_to

    #
    # Parses job's annotations and initializes the RactorRunner.
    #
    def initialize
      super

      @runner = ETL::RactorRunner.new(*parse_ractor_annotations)
    end

    #
    # Initializes ractors and waits for them to finish.
    #
    # @return [void]
    #
    def run
      @runner.create_ractors!
      @runner.take_ractors!
    end
  end
end
