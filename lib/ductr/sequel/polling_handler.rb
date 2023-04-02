# frozen_string_literal: true

module Ductr
  module Sequel
    #
    # The rufus-scheduler handler class.
    # @see https://github.com/jmettraux/rufus-scheduler#scheduling-handler-instances
    #   For further information
    #
    class PollingHandler
      #
      # Creates the handler based on the given scheduler, its method name and the trigger's adapter instance.
      #
      # @param [Method] method The scheduler's method
      # @param [Ductr::Adapter] adapter The trigger's adapter
      #
      def initialize(method, adapter)
        @method = method
        @adapter = adapter
        @last_triggering_key = nil
      end

      #
      # The callable method used by the trigger, actually calls the scheduler's method.
      #
      # @return [void]
      #
      def call
        @adapter.open do |db|
          @method.call(db) do |triggering_key|
            return false if triggering_key == @last_triggering_key

            @last_triggering_key = triggering_key
            true
          end
        end
      end
    end
  end
end
