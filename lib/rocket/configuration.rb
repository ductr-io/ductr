# frozen_string_literal: true

require "semantic_logger"
require "config"

module Rocket
  #
  # Contains the framework's configuration, including:
  # - `ROCKET_ENV` environment variable
  # - `Rocket.configure` block
  # - Project root path
  # - YML file configuration
  #
  class Configuration
    # @return [String] The Rocket environment
    attr_reader :env

    # @return [Module<SemanticLogger>] The semantic logger constant
    # @see https://logger.rocketjob.io/api.html For further documentation
    attr_reader :logging

    # @return [String] The project root
    attr_reader :root

    # @return [Hash] The parsed YML configuration
    attr_reader :yml

    #
    # Initializing environment to "development" by default, setting project root, parsing YML with the config gem
    # and aliasing semantic logger gem constant to make it usable through the `Rocket.configure` block
    #
    def initialize
      @env = ENV.fetch("ROCKET_ENV", "development")
      @root = Dir.pwd
      @yml = Config.load_files("#{root}/config/#{env}.yml")
      @logging = SemanticLogger
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
    # Memoize configured adapters based on the YAML configuration.
    #
    # @return [Array<Adapter>] The configured Adapter instances
    #
    def adapters
      @adapters ||= yml.adapters.map do |name, entry|
        adapter_class = Rocket.adapter_registry.find_by_type(entry.adapter)
        config = entry.to_h.except(:adapter)

        adapter_class.new(name, **config)
      end
    end

    #
    # Find an adapter based on its name.
    #
    # @param [Symbol] name The name of the adapter to find
    #
    # @raise [AdapterNotFoundError] If no adapter match the given name
    # @return [Adapter] The adapter found
    #
    def adapter(name)
      not_found_error = -> { raise AdapterNotFoundError, "The adapter named \"#{name}\" does not exist" }

      adapters.find(not_found_error) do |adapter|
        adapter.name == name
      end
    end
  end
end
