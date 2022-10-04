# frozen_string_literal: true
require "active_support/cache/file_store"

Rocket.configure do |config|
  # Store configuration.
  #
  # You can pass an `ActiveSupport::Cache::Store` class or a symbol
  config.store(ActiveSupport::Cache::FileStore, "tmp/store")

  # Logging configuration.
  #
  # The following logging levels are available:
  # :debug, :info, :warn, :error, :fatal
  config.logging.level = :debug

  # Append logs to the stdout by default, you can add/replace outputs at will.
  config.logging.add_output(Rocket::Log::StandardOutput, Rocket::Log::ColorFormatter)
end
