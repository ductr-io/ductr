# frozen_string_literal: true

require "yaml"
require "erb"

module Ductr
  #
  # Contains the framework's configuration, including:
  # - `DUCTR_ENV` environment variable
  # - `Ductr.configure` block
  # - Project root path
  # - YML file configuration
  #
  class Configuration
    # @return [Struct] The active job configuration, available options are
    #                  `queue_adapter`, `default_queue_name`, `queue_name_prefix` & `queue_name_delimiter`
    attr_reader :active_job

    # @return [Class<Ductr::Log::Logger>] The logger constant
    attr_reader :logging

    # @return [String] The project root
    attr_reader :root

    # @return [Class<ActiveSupport::Cache::Store>, Symbol] The store adapter to use
    #   @see https://edgeapi.rubyonrails.org/classes/ActiveSupport/Cache.html#method-c-lookup_store
    attr_reader :store_adapter

    # @return [Array] The store adapter config args
    attr_reader :store_parameters

    # @return [Hash<Symbol, Object>] The store adapter config options
    attr_reader :store_options

    # @return [Hash] The parsed YML configuration
    attr_reader :yml

    #
    # Initializing environment to "development" by default, setting project root, parsing YML with the config gem
    # and aliasing semantic logger gem constant to make it usable through the `Ductr.configure` block
    #
    def initialize(env)
      @root = Dir.pwd
      @yml = load_yaml("#{root}/config/#{env}.yml")

      @logging = Log::Logger
      logging.level = :debug

      @active_job = Struct.new(:queue_adapter, :default_queue_name, :queue_name_prefix, :queue_name_delimiter).new
      @store_adapter = ActiveSupport::Cache::FileStore
      @store_parameters = ["tmp/store"]
    end

    #
    # Configures the store instance.
    #
    # @param [Class<ActiveSupport::Cache::Store>, Symbol] adapter The store adapter class
    # @param [Array] *parameters The store adapter configuration
    #
    # @return [void]
    #
    def store(adapter, *parameters, **options)
      @store_adapter = adapter
      @store_parameters = parameters
      @store_options = options
    end

    #
    # Memoize configured adapters based on the YAML configuration.
    #
    # @return [Array<Adapter>] The configured Adapter instances
    #
    def adapters
      @adapters ||= yml.adapters.to_h.map do |name, entry|
        adapter_class = Ductr.adapter_registry.find(entry.adapter)
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

    #
    # Configures active job with the given options.
    #
    # @return [void]
    #
    def apply_active_job_config
      ActiveJob::Base.logger = logging.new("ActiveJob")

      active_job.each_pair do |opt, value|
        next unless value

        ActiveJob::Base.send("#{opt}=", value)
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
