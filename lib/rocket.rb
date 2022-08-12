# frozen_string_literal: true

require "zeitwerk"

Zeitwerk::Loader.for_gem.tap do |loader|
  loader.inflector.inflect "cli" => "CLI"
  loader.inflector.inflect "etl" => "ETL"
  loader.inflector.inflect "dsl" => "DSL"

  loader.collapse "#{__dir__}/rocket/etl/controls"
  loader.collapse "#{__dir__}/rocket/log/outputs"
  loader.collapse "#{__dir__}/rocket/log/formatters"

  loader.ignore "#{__dir__}/rocket/cli/templates"

  loader.setup
end

#
# The main rocket module.
#
module Rocket
  class AdapterNotFoundError < StandardError; end
  class ControlNotFoundError < StandardError; end
  class InconsistentPaginationError < StandardError; end

  class << self
    #
    # Contains all the Rocket configuration.
    #
    # @return [Configuration] The configuration instance
    attr_reader :config

    #
    # The adapter classes registry, all declared adapters are in the registry.
    #
    # @return [AdapterRegistry] The registry instance
    #
    def adapter_registry
      @adapter_registry ||= AdapterRegistry.new
    end

    #
    # The Rocket current environment, "development" by default.
    # You can change it by setting the `ROCKET_ENV` environment variable.
    #
    # @return [String] The Rocket environment
    #
    def env
      ENV.fetch("ROCKET_ENV", "development")
    end

    #
    # Determines if Rocket is in development mode.
    #
    # @return [Boolean] True if ROCKET_ENV is set to "development" or nil
    #
    def development?
      env == "development"
    end

    #
    # Determines if Rocket is in production mode.
    #
    # @return [Boolean] True if ROCKET_ENV is set to "production"
    #
    def production?
      env == "production"
    end

    #
    # The configure block allows to configure Rocket internals.
    # You must calls this method one and only one time to use the framework.
    #
    # @return [void]
    # @yield [config] Configure the framework
    # @yieldparam [Configuration] config The configuration instance
    #
    def configure
      @config = Configuration.new(env)
      yield(@config)

      Ractor.make_shareable @config
      Ractor.make_shareable @adapter_registry
      Ractor.make_shareable @config.logging.outputs
      @adapter_registry.adapters.each(&:make_shareable)
    end

    #
    # The Rocket main logger instance.
    #
    # @return [SemanticLogger::Logger] The logger instance
    #
    def logger
      @logger ||= config.logging.new
    end
  end
end
