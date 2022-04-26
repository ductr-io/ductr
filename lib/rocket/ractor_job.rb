# frozen_string_literal: true

module Rocket
  class RactorJob < Job
    annotable :source, :lookup, :destination, :transform, :send_to

    include ETL::RactorRunner
  end
end
