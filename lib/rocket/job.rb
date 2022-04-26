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
      not_found_error = -> { raise AdapterNotFoundError, "The adapter named \"#{name}\" does not exist" }

      Rocket.config.adapters.find(not_found_error) do |adapter|
        adapter.name == name
      end
    end

    def logger
      Rocket.config.logging[self.class]
    end
  end
end
