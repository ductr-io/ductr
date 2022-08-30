# frozen_string_literal: true

module Rocket
  #
  # Base class for ETL job using kiba's streaming runner.
  # Example using the SQLite adapter:
  #
  #   class MyKibaJob < Rocket::KibaJob
  #     source :some_adapter, :paginated, page_size: 4
  #     def select_some_stuff(db, offset, limit)
  #       db[:items].offset(offset).limit(limit)
  #     end
  #
  #     lookup :some_adapter, :match, merge: [:id, :item], buffer_size: 4
  #     def merge_with_stuff(db, ids)
  #       db[:items_bis].select(:id, Sequel.as(:name, :name_bis), :item).where(item: ids)
  #     end
  #
  #     transform
  #     def generate_more_stuff(row)
  #       { name: "#{row[:name]}_#{row[:name_bis]}" }
  #     end
  #
  #     destination :some_other_adapter, :basic
  #     def my_destination(row, db)
  #       logger.trace("Hello destination: #{row}")
  #       db[:new_items].insert(name: row[:name])
  #     end
  #   end
  #
  # @see The chosen adapter documentation for further information on controls usage.
  #
  class KibaJob < Job
    annotable :source, :transform, :lookup, :destination

    #
    # Parses job's annotations and initializes the KibaRunner.
    #
    def initialize(...)
      super(...)

      @runner = ETL::KibaRunner.new(*parse_annotations)
    end

    #
    # Starts the runner.
    #
    # @return [void]
    #
    def run
      @runner.run
    end
  end
end
