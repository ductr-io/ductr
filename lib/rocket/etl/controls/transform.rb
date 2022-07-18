# frozen_string_literal: true

module Rocket
  module ETL
    class Transform < Control
      def process(row)
        call_method(row)
      end

      def close
        adapter&.close!
      end
    end
  end
end
