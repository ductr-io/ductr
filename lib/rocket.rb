# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.tap do |loader|
  loader.inflector.inflect "cli" => "CLI"
  loader.inflector.inflect "etl" => "ETL"
  loader.inflector.inflect "dsl" => "DSL"

  loader.collapse "#{__dir__}/rocket/etl/controls"
  loader.ignore "#{__dir__}/rocket/cli/templates"

  loader.setup
end

#
# The main rocket module.
#
module Rocket
  class AdapterNotFoundError < StandardError; end
  class InconsistentPaginationError < StandardError; end

  class << self
    #
    # The adapter instances registry, all declared connectors are in the registry.
    #
    # @return [AdapterRegistry] The registry instance
    #
    def adapter_registry
      @adapter_registry ||= AdapterRegistry.new
    end

    #
    # Contains all the Rocket configuration.
    #
    # @return [Configuration] The configuration instance
    #
    def config
      @config ||= Configuration.new
    end

    #
    # The configure block allows to configure Rocket internals.
    #
    # @return [void]
    # @yield [config] Configure the framework
    # @yieldparam config [Configuration] The configuration instance
    #
    def configure
      yield(config)
    end

    #
    # The Rocket main logger instance.
    #
    # @return [SemanticLogger::Logger] The logger instance
    #
    def logger
      @logger ||= config.logging[Rocket]
    end
  end
end
