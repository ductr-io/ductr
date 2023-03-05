# frozen_string_literal: true

module Ductr
  #
  # The base class for any trigger, can be initialized by passing it its adapter name if any.
  # A trigger must implement the #add method which is called for each trigger declaration.
  # Depending on what your trigger do, you may have to implement the #start and #stop methods.
  # #start is called when the scheduler relying on the trigger is started. #stop does the opposite:
  # it is called when the scheduler relying on the trigger is stopped.
  #
  class Trigger
    attr_reader :adapter

    #
    # Creates a new trigger instance, called by the scheduler.
    #
    # @param [Adapter, Nil] adapter The trigger's adapter, if any
    #
    def initialize(adapter = nil)
      @adapter = adapter
    end

    #
    # Adds a new trigger, called by a scheduler when a trigger is declared.
    #
    # @param [Method] _method The scheduler method to be called by the trigger
    # @param [Hash<Symbol: Object>] _options options The options of the trigger declaration
    #
    # @return [void]
    #
    def add(_method, _options)
      raise NotImplementedError, "A trigger must implement the #add method"
    end

    #
    # Called when the scheduler relying on the trigger is started.
    #
    # @return [void]
    #
    def start; end

    #
    # Called when the scheduler relying on the trigger is stopped.
    #
    # @return [void]
    #
    def stop; end
  end
end
