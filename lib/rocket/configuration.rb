# frozen_string_literal: true

require "yaml"
require "erb"

module Rocket
  #
  # Contains the framework's configuration, including:
  # - `ROCKET_ENV` environment variable
  # - `Rocket.configure` block
  # - Project root path
  # - YML file configuration
  #
  class Configuration
    # @return [Class<Rocket::Log::Logger>] The logger constant
    attr_reader :logging

    # @return [String] The project root
    attr_reader :root

    # @return [Hash] The parsed YML configuration
    attr_reader :yml

    #
    # Initializing environment to "development" by default, setting project root, parsing YML with the config gem
    # and aliasing semantic logger gem constant to make it usable through the `Rocket.configure` block
    #
    def initialize(env)
      @root = Dir.pwd
      @yml = load_yaml("#{root}/config/#{env}.yml")
      @logging = Log::Logger
    end

    #
    # Memoize configured adapters based on the YAML configuration.
    #
    # @return [Array<Adapter>] The configured Adapter instances
    #
    def adapters
      yml.adapters.to_h.map do |name, entry|
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

    private

    #
    # Load YAML configuration localized at given path.
    # Parse the file with ERB before parsing YAML, so we can use env vars in config files.
    #
    # @param [String] path The path of the YAML file to load
    #
    # @return [Struct] The parsed YAML configuration
    #
    def load_yaml(path)
      return {} unless path && File.exist?(path)

      erb = ERB.new File.read(path)
      yaml = YAML.load(erb.result, symbolize_names: true)

      hash_to_struct(yaml)
    end

    #
    # Recursively convert Hash into Struct.
    #
    # @param [Hash] hash The hash to convert
    #
    # @return [Struct] The converted hash
    #
    def hash_to_struct(hash)
      values = hash.values.map do |value|
        next hash_to_struct(value) if value.is_a?(Hash)

        value
      end

      Struct.new(*hash.keys).new(*values)
    end
  end
end
