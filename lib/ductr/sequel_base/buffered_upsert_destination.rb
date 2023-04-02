# frozen_string_literal: true

module Ductr
  module SequelBase
    #
    # A destination control that accumulates rows in a buffer to upsert them by batch.
    #
    class BufferedUpsertDestination < Ductr::ETL::BufferedDestination
      #
      # Open the database if needed and call the job's method to run the query.
      #
      # @return [void]
      #
      def on_flush
        call_method(adapter.db, excluded, buffer)
      end

      private

      #
      # Generate the excluded keys hash e.g.
      #
      # ```ruby
      # {a: Sequel[:excluded][:a]}
      # ```
      #
      # @return [Hash<Symbol, Sequel::SQL::QualifiedIdentifier>] The excluded keys hash
      #
      def excluded
        keys = buffer.first.keys

        excluded_keys = keys.map do |key|
          Sequel[:excluded][key]
        end

        keys.zip(excluded_keys).to_h
      end
    end
  end
end
