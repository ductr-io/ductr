# frozen_string_literal: true

module Ductr
  module SequelBase
    #
    # A trigger based on the RufusTrigger, runs the PollingHandler at the given timing.
    #
    class PollingTrigger < Ductr::RufusTrigger
      #
      # Closes the connection if the scheduler is stopped.
      #
      # @return [void]
      #
      def stop
        super
        adapter.close!
      end

      private

      #
      # Returns a callable object, allowing rufus-scheduler to call it.
      #
      # @param [Ductr::Scheduler] scheduler The scheduler instance
      # @param [Method] method The scheduler's method
      # @param [Hash] ** The option passed to the trigger annotation
      #
      # @return [#call] A callable object
      #
      def callable(method, **)
        PollingHandler.new(method, adapter)
      end
    end
  end
end
