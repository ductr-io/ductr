# frozen_string_literal: true

module Ductr
  #
  # Base class for ETL job using kiba's streaming runner.
  # Example using the SQLite adapter:
  #
  #   class MyKibaJob < Ductr::KibaJob
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
    # @return [Class] The ETL runner class used by the job
    ETL_RUNNER_CLASS = ETL::KibaRunner
    include JobETLRunner

    include ETL::Parser

    #
    # @!method self.source(adapter_name, source_type, **source_options)
    #   Annotation to define a source method
    #   @param adapter_name [Symbol] The adapter the source is running on
    #   @param source_type [Symbol] The type of source to run
    #   @param **source_options [Hash<Symbol: Object>] The options to pass to the source
    #
    #   @example Source with Sequel SQLite adapter
    #     source :my_adapter, :paginated, page_size: 42
    #     def my_source(db, offset, limit)
    #       db[:items].offset(offset).limit(limit)
    #     end
    #
    #   @see The chosen adapter documentation for further information on sources usage.
    #
    #   @return [void]
    #
    annotable :source

    #
    # @!method self.transform(transform_class, **transform_options)
    #   Annotation to define a transform method
    #   @param transform_class [Class, nil] The class the transform is running on
    #   @param **transform_options [Hash<Symbol: Object>] The options to pass to the transform
    #
    #   @example Transform without params
    #     transform
    #     def rename_keys(row)
    #       row[:new_name] = row.delete[:old_name]
    #       row[:new_email] = row.delete[:old_email]
    #     end
    #
    #   @example Transform with params
    #     class RenameTransform < Ductr::ETL::Transform
    #       def process(row)
    #         call_method.each do |actual_name, new_name|
    #           new_key = "#{options[:prefix]}#{new_name}".to_sym
    #
    #           row[new_key] = row.delete(actual_name)
    #         end
    #       end
    #     end
    #
    #     transform RenameTransform, prefix: "some_"
    #     def rename
    #       { old_name: :new_name, old_email: :new_email }
    #     end
    #
    #   @return [void]
    #
    annotable :transform

    #
    # @!method self.lookup(adapter_name, lookup_type, **lookup_options)
    #   Annotation to define a lookup method
    #   @param adapter_name [Symbol] The adapter the lookup is running on
    #   @param lookup_type [Symbol] The type of lookup to run
    #   @param **lookup_options [Hash<Symbol: Object>] The options to pass to the lookup
    #
    #   @example Lookup with Sequel SQLite adapter
    #     lookup :my_other_adapter, :match, merge: [:id, :item], buffer_size: 4
    #     def joining_different_adapters(db, ids)
    #       db[:items_bis].select(:id, :item, :name).where(item: ids)
    #     end
    #
    #   @see The chosen adapter documentation for further information on lookups usage.
    #
    #   @return [void]
    #
    annotable :lookup

    #
    # @!method self.destination(adapter_name, destination_type, **destination_options)
    #   Annotation to define a destination method
    #   @param adapter_name [Symbol] The adapter the destination is running on
    #   @param destination_type [Symbol] The type of destination to run
    #   @param **destination_options [Hash<Symbol: Object>] The options to pass to the destination
    #
    #   @example Destination with Sequel SQLite adapter
    #     destination :my_other_adapter, :basic
    #     def my_destination(row, db)
    #       db[:new_items].insert(name: row[:name], new_name: row[:new_name])
    #     end
    #
    #   @see The chosen adapter documentation for further information on destinations usage.
    #
    #   @return [void]
    #
    annotable :destination
  end
end
