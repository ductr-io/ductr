# frozen_string_literal: true

module Rocket
  module ETL
    class PaginatedSource < Source
      def page_size
        @options[:page_size]
      end

      def each(&)
        @offset ||= 0

        loop do
          break unless each_page(&)

          @offset += page_size
        end
      end
    end
  end
end
