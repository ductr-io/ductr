# frozen_string_literal: true

module Ductr
  module Sequel
    #
    # The base class of all sequel-based adapters.
    #
    class Adapter < Ductr::Adapter
      # @return [Sequel::Database, nil] The database connection instance
      attr_reader :db
    end
  end
end
