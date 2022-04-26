# frozen_string_literal: true

module Rocket
  module ETL
    class Source < Control
      def each(&)
        call_method.each(&)
      end
    end
  end
end
