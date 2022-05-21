# frozen_string_literal: true

module Rocket
  class Job
    extend ETL::Annotable
    include ETL::Parser

    attr_reader :params

    def perform(*params)
      @params = params
      run
    end

    def adapter(name)
      Rocket.config.adapter(name)
    end

    def logger
      Rocket.config.logging[self.class]
    end
  end
end
