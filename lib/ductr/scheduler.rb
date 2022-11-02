# frozen_string_literal: true

module Ductr
  #
  # Base class to declare event driven scheduling.
  # Example using the schedule trigger:
  #
  #   class MyScheduler < Ductr::Scheduler
  #     trigger :schedule, every: "10min"
  #     def every_ten_minutes
  #       MyJob.perform_later
  #     end
  #   end
  #
  class Scheduler
    extend Annotable

    #
    # @!method self.trigger(trigger_type, adapter_name = nil, **trigger_options)
    #   Annotation to define a trigger method
    #   @param trigger_type [Symbol] The trigger's type
    #   @param adapter_name [Symbol] The trigger's adapter (if any)
    #   @param **trigger_options [Hash<Symbol: Object>] The options to pass to the trigger
    #
    #   @example A schedule trigger
    #     trigger :schedule, every: "10min"
    #     def every_ten_minutes
    #       MyJob.perform_later
    #     end
    #
    #   @see The chosen trigger documentation for further information.
    #
    #   @return [void]
    #
    annotable :trigger

    class << self
      #
      # All trigger instances are stored in a singleton hash, avoiding to create the same trigger multiple times.
      #
      # @return [Hash<Symbol: Trigger>] The singleton hash containing all trigger instances
      #
      def triggers
        @triggers ||= {}
      end

      #
      # Calls #start on all created triggers.
      #
      # @return [void]
      #
      def start
        triggers.values.each(&:start)
      end

      #
      # Calls #stop on all created triggers.
      #
      # @return [void]
      #
      def stop
        triggers.values.each(&:stop)
      end
    end

    #
    # Parses trigger annotations, creates triggers if needed and calls #add on trigger instances.
    #
    def initialize
      self.class.annotated_methods.each do |method|
        annotation = method.find_annotation(:trigger)
        trigger = find_trigger(*annotation.params.reverse)

        trigger.add(self, method.name, annotation.options)
      end
    end

    private

    #
    # Finds a trigger in the according trigger registry based on its type and adapter name if given.
    #
    # @param [Symbol] trigger_type The trigger type, e.g. `:schedule`
    # @param [Symbol] adapter_name The adapter name, e.g. `:my_adapter`
    #
    # @return [Trigger] The found trigger
    #
    def find_trigger(trigger_type, adapter_name = nil)
      return find_or_create_trigger(Ductr.trigger_registry, trigger_type) unless adapter_name

      trigger_registry = Ductr.config.adapter(adapter_name).class.trigger_registry
      registry_key = "#{adapter_name}_#{trigger_type}".to_sym

      find_or_create_trigger(trigger_registry, registry_key, trigger_type, adapter_name)
    end

    #
    # Find a trigger in the singleton hash. if none found, find the trigger class in the given registry,
    # initializes it and store the instance in the singleton hash.
    #
    # @param [Registry] trigger_registry The registry containing the required trigger class
    # @param [Symbol] registry_key The key in which to store the trigger instance inside the singleton hash
    # @param [Symbol] trigger_type The registry's key in which to find the trigger class
    # @param [Symbol] adapter_name The adapter name to pass to the trigger
    #
    # @return [Trigger] The found or created trigger
    #
    def find_or_create_trigger(trigger_registry, registry_key, trigger_type = registry_key, adapter_name = nil)
      trigger = Scheduler.triggers[registry_key]
      return trigger if trigger

      Scheduler.triggers[registry_key] = trigger_registry.find(trigger_type).new(adapter_name)
    end
  end
end
