# frozen_string_literal: true

module Ductr
  module ETL
    #
    # Base class to implement paginated source.
    #
    class PaginatedSource < Source
      #
      # The page size option, default to 10_000.
      #
      # @return [Integer] The page size
      #
      def page_size
        @options[:page_size] || 10_000
      end

      #
      # Iterates over pages and calls #each_page.
      #
      # @yield [row] The row yielder
      #
      # @return [void]
      #
      def each(&)
        @offset ||= 0

        loop do
          break unless each_page(&)

          @offset += page_size
        end
      end

      #
      # Called once per pages.
      #
      # @yield [row] The row yielder
      #
      # @return [void]
      #
      def each_page(&)
        raise NotImplementedError, "A paginated source must implement the `#each_page` method"
      end
    end
  end
end
