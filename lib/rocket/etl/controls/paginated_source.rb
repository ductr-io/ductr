# frozen_string_literal: true

module Rocket
  module ETL
    class PaginatedSource < Source
      def page_size
        @options[:page_size] || 10_000
      end

      def each(&)
        adapter.open!
        @offset ||= 0

        loop do
          break unless each_page(&)

          @offset += page_size
        end

        adapter.close!
      end
    end
  end
end
