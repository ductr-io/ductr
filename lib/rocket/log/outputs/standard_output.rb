# frozen_string_literal: true

require "logger"

module Rocket
  module Log
    #
    # The STDOUT logger output
    #
    class StandardOutput
      # @return [Array<String>] The labels to associate to severity integers
      SEVERITY_LABELS = %w[DEBUG INFO WARN ERROR FATAL ANY].freeze

      #
      # Creates a logger output instance
      #
      # @param [::Logger::Formatter] formatter The formatter to use to write the logs in STDOUT
      # @param [Hash] **options The LogDevice options
      #
      def initialize(formatter, **options)
        @formatter = formatter.new
        @log_device = ::Logger::LogDevice.new $stdout, **options
      end

      #
      # Writes the log to the STDOUT
      #
      # @param [Integer] severity The log's severity level
      # @param [Symbol] prog_name The "program" name, used to add job method name to the log
      # @param [String] message The log message
      #
      # @return [void]
      #
      def write(severity, prog_name, message)
        @log_device.write @formatter.call(SEVERITY_LABELS[severity], Time.now, prog_name, message)
      end
    end
  end
end
