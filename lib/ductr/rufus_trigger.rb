# frozen_string_literal: true

require "rufus-scheduler"

module Ductr
  #
  # A time related trigger, used to trigger jobs or pipelines based on temporal events.
  # The trigger is registered as `:schedule`:
  #
  #   trigger :schedule, every: "1min"
  #   def every_minute
  #     MyPipeline.perform_later
  #   end
  #
  # This trigger is based on the `rufus-scheduler` gem.
  # Under the hood, the internal method `Rufus::Scheduler#do_schedule` is used.
  #
  # There are 4 types of options available:
  #
  # - `:once`, used to schedule at a given time
  #
  #   trigger :schedule, once: "10d" # Will run in ten days
  #   trigger :schedule, once: "2042/12/12 23:59:00" # Will run at the given date
  #
  # - `:every`, triggers following the given frequency
  #
  #   trigger :schedule, every: "1min" # will run every minute.
  #
  # - `:interval`, run the trigger then waits the given interval before running again
  #
  #   # Will run every 4 + 1 seconds
  #   trigger :schedule, interval: "4s"
  #   def every_interval
  #     sleep(1)
  #     MyPipeline.perform_later
  #   end
  #
  # - `:cron`, run the trigger following the given crontab pattern
  #
  #   trigger :schedule, cron: "00 01 * * *" # Will run every day at 1am.
  #
  class RufusTrigger < Trigger
    Ductr.trigger_registry.add self, as: :schedule

    #
    # Adds a new trigger into rufus-scheduler.
    #
    # @param [Symbol] method The scheduler method to be called by rufus-scheduler
    # @param [Hash<Symbol: String>] options The options to configure rufus-scheduler
    #
    # @return [void]
    #
    def add(method, options)
      rufus_type = options.keys.first
      rufus_value = options.values.first

      do_schedule(rufus_type, rufus_value, method)
    end

    #
    # Shutdown rufus-scheduler
    #
    # @return [void]
    #
    def stop
      rufus.shutdown
    end

    private

    #
    # Shortcut to get the rufus-scheduler singleton
    #
    # @return [Rufus::Scheduler] The rufus-scheduler instance
    #
    def rufus
      Rufus::Scheduler.singleton
    end

    #
    # Returns a callable object based on given scheduler, method_name and options.
    #
    # @param [Scheduler] scheduler The scheduler instance
    # @param [Symbol] method_name The scheduler's method name
    # @param [Hash] ** The option passed to the trigger annotation
    #
    # @return [#call] A callable object
    #
    def callable(scheduler, method_name, **)
      scheduler.method(method_name)
    end

    #
    # Calls the Rufus::Scheduler#do_schedule private method with rufus-scheduler type, value and the callable object.
    #
    # @param [Symbol] rufus_type The rufus-scheduler type (`:once`, `:every`, `:interval` or `:cron`)
    # @param [String] rufus_value The rufus-scheduler value (e.g. `"10min"`)
    # @param [#call] method The callable object (the scheduler's method in this case)
    #
    # @return [void]
    #
    def do_schedule(rufus_type, rufus_value, method)
      rufus.send(:do_schedule, rufus_type, rufus_value, nil, {}, false, method)
    end
  end
end
