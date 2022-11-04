# frozen_string_literal: true

require "active_job"
require "annotable"
require "forwardable"
require "zeitwerk"

#
# The main Ductr module.
#
module Ductr
  class AdapterNotFoundError < StandardError; end
  class ControlNotFoundError < StandardError; end
  class InconsistentPaginationError < StandardError; end

  class << self
    #
    # Contains all the Ductr configuration.
    #
    # @return [Configuration] The configuration instance
    attr_reader :config

    #
    # The adapter classes registry, all declared adapters are in the registry.
    #
    # @return [Registry] The registry instance
    #
    def adapter_registry
      @adapter_registry ||= Registry.new(:adapter)
    end

    #
    # The trigger classes registry, all declared triggers are in the registry.
    #
    # @return [Registry] The registry instance
    #
    def trigger_registry
      @trigger_registry ||= Registry.new(:trigger)
    end

    #
    # The Ductr current environment, "development" by default.
    # You can change it by setting the `DUCTR_ENV` environment variable.
    #
    # @return [String] The Ductr environment
    #
    def env
      @env ||= ENV.fetch("DUCTR_ENV", "development").downcase
    end

    #
    # Determines if Ductr is in development mode.
    #
    # @return [Boolean] True if DUCTR_ENV is set to "development" or nil
    #
    def development?
      env == "development"
    end

    #
    # Determines if Ductr is in production mode.
    #
    # @return [Boolean] True if DUCTR_ENV is set to "production"
    #
    def production?
      env == "production"
    end

    #
    # The configure block allows to configure Ductr internals.
    # You must calls this method one and only one time to use the framework.
    #
    # @return [void]
    # @yield [config] Configure the framework
    # @yieldparam [Configuration] config The configuration instance
    #
    def configure
      @config = Configuration.new(env)
      yield(@config)
      @config.apply_active_job_config

      Ractor.make_shareable @config
      Ractor.make_shareable @adapter_registry
      Ractor.make_shareable @config.logging.outputs
      adapter_registry.values.each(&:make_shareable)
    end

    #
    # The Ductr main logger instance.
    #
    # @return [Log::Logger] The logger instance
    #
    def logger
      @logger ||= config.logging.new
    end

    #
    # The Ductr store, used to share information across different instances.
    #
    # @return [ActiveSupport::Cache::Store] The store instance
    #
    def store
      @store ||= \
        if config.store_adapter.is_a? Class
          config.store_adapter.new(*config.store_parameters)
        else
          ActiveSupport::Cache.lookup_store(config.store_adapter, *config.store_parameters)
        end
    end
  end
end

#
# Framework auto loading
#
Zeitwerk::Loader.for_gem.tap do |loader|
  loader.inflector.inflect "cli" => "CLI"
  loader.inflector.inflect "etl" => "ETL"

  loader.collapse "#{__dir__}/ductr/etl/controls"
  loader.collapse "#{__dir__}/ductr/log/outputs"
  loader.collapse "#{__dir__}/ductr/log/formatters"

  loader.ignore "#{__dir__}/ductr/cli/templates"

  loader.setup
  loader.eager_load_namespace(Ductr::RufusTrigger)
end

#
# Application auto loading
#
if File.directory?("#{Dir.pwd}/app")
  Zeitwerk::Loader.new.tap do |loader|
    loader.push_dir "#{Dir.pwd}/app"

    loader.collapse "#{Dir.pwd}/app/jobs"
    loader.collapse "#{Dir.pwd}/app/pipelines"
    loader.collapse "#{Dir.pwd}/app/schedulers"

    loader.setup
  end
end
