# frozen_string_literal: true

module Rocket
  module ETL
    class Destination < Control
      def write(row)
        call_method(row)
      end

      def close; end
    end
  end
end
