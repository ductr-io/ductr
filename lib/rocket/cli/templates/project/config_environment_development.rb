# frozen_string_literal: true

Rocket.configure do |config|
  # Logging configuration, rely on the Semantic Logger gem.
  #
  # The following logging levels are available:
  # :trace, :debug, :info, :warn, :error, :fatal
  # See https://logger.rocketjob.io/api.html for further details about logging levels.
  config.logging.default_level = :trace

  # Append logs to the stdout by default, you add/replace appenders at will.
  # see https://logger.rocketjob.io/appenders.html for further information about appenders.
  config.logging.add_appender(io: $stdout)
end
