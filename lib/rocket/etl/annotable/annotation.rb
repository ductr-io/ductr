# frozen_string_literal: true

module Rocket
  module ETL
    module Annotable
      class Annotation
        attr_reader :name, :params, :options, :block

        def initialize(name, params, options)
          @name = name.freeze
          @params = params.freeze
          @options = options.freeze
        end
      end
    end
  end
end
