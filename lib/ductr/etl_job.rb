# frozen_string_literal: true

module Ductr
  #
  # Base class for ETL job using the experimental fiber runner.
  # Usage example:
  #
  #   class MyETLJob < Ductr::ETLJob
  #     source :first_db, :basic
  #     send_to :the_transform, :the_other_transform
  #     def the_source(db)
  #       # ...
  #     end
  #
  #     transform
  #     send_to :the_destination
  #     def the_transform(row)
  #       # ...
  #     end
  #
  #     destination :first_db, :basic
  #     def the_destination(row, db)
  #       # ...
  #     end
  #
  #     transform
  #     send_to :the_other_destination
  #     def the_other_transform(row)
  #       # ...
  #     end
  #
  #     destination :second_db, :basic
  #     def the_other_destination(row, db)
  #       # ...
  #     end
  #   end
  #
  class ETLJob < Job
    # @return [Class] The ETL runner class used by the job
    ETL_RUNNER_CLASS = ETL::FiberRunner
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

    #
    # @!method self.send_to(*methods)
    #   Annotation to define which methods will follow the current one
    #   @param *methods [Array<Symbol>] The names of the following methods
    #
    #   @example Source with Sequel SQLite adapter sending rows to two transforms
    #     source :my_adapter, :paginated, page_size: 42
    #     send_to :my_first_transform, :my_second_transform
    #     def my_source(db, offset, limit)
    #       db[:items].offset(offset).limit(limit)
    #     end
    #
    #     transform
    #     def my_first_transform(row)
    #       # ...
    #     end
    #
    #     transform
    #     def my_second_transform(row)
    #       # ...
    #     end
    #
    #   @return [void]
    #
    annotable :send_to
  end
end
