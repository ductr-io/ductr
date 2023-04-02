# frozen_string_literal: true

module Ductr
  module SequelBase
    #
    # A source control that allows to select a big number of rows by relying on pagination.
    #
    class PaginatedSource < Ductr::ETL::PaginatedSource
      #
      # Calls the job's method and iterate on the query result.
      # Returns true if the page is full, false otherwise.
      #
      # @yield The each block
      #
      # @raise [InconsistentPaginationError] When the query return more rows than the page size
      # @return [Boolean] True if the page is full, false otherwise.
      #
      def each_page(&)
        rows_count = 0

        call_method(adapter.db, @offset, page_size).each do |row|
          yield(row)
          rows_count += 1
        end

        if rows_count > page_size
          raise InconsistentPaginationError,
                "The query returned #{rows_count} rows but the page size is #{page_size} rows"
        end

        rows_count == page_size
      end
    end
  end
end
