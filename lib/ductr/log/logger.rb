# frozen_string_literal: true

require "logger"

module Ductr
  module Log
    #
    # A ractor compatible logger to be used inside jobs or anywhere else in your ductr project.
    #
    class Logger
      class << self
        #
        # Allows to add another log output.
        # Making possible to write logs in multiple places at the same time, e.g. in STDOUT and in logs files
        #
        # @param [StandardOutput] output The new output to write logs to
        # @param [::Logger::Formatter] formatter The formatter to use when writing logs
        # @param [Hash] **options The formatter options
        #
        # @return [void]
        #
        def add_output(output, formatter = ::Logger::Formatter, **options)
          @outputs ||= []
          @outputs.push([output, [formatter, options]])
        end

        #
        # The configured outputs list
        #
        # @return [Array<Array<StandardOutput, Array<::Logger::Formatter, Hash>>>]
        #   The list of outputs with their formatters and configurations
        #
        def outputs
          @outputs || [[StandardOutput, [::Logger::Formatter]]]
        end

        #
        # Configure the logging level.
        #
        # @param [Symbol, String] lvl The desired logging level
        #
        # @return [void]
        #
        def level=(lvl)
          level_sym = lvl.to_s.downcase.to_sym
          @level = {
            debug: ::Logger::DEBUG,
            info: ::Logger::INFO,
            warn: ::Logger::WARN,
            error: ::Logger::ERROR,
            fatal: ::Logger::FATAL
          }[level_sym]

          raise ArgumentError, "invalid log level: #{lvl}" unless @level
        end

        #
        # @return [Integer] The current logging level, default ::Logger::DEBUG
        #
        def level
          @level || ::Logger::DEBUG
        end
      end

      #
      # Create configured outputs instances, meaning that you can't add outputs in an already instantiated logger.
      #
      def initialize(prog_name = nil)
        @prog_name = prog_name

        @outputs = self.class.outputs.map do |output_with_params|
          out, params = *output_with_params
          formatter, options = *params

          out.new(formatter, **options || {})
        end
      end

      #
      # Logs a message with the `debug` level.
      #
      # @param [String] message The message to log
      # @param [String, Symbol] prog_name The program name of the message
      #
      # @return [void]
      # @yield The message
      #
      def debug(...)
        write(::Logger::DEBUG, ...)
      end

      #
      # Returns true if the log level allows entries with severity Logger::DEBUG to be written, false otherwise.
      #
      # @return [Boolean]
      #
      def debug?
        self.class.level <= ::Logger::DEBUG
      end

      #
      # Logs a message with the `info` level.
      #
      # @param [String] message The message to log
      # @param [String, Symbol] prog_name The program name of the message
      #
      # @return [void]
      # @yield The message
      #
      def info(...)
        write(::Logger::INFO, ...)
      end

      #
      # Returns true if the log level allows entries with severity Logger::INFO to be written, false otherwise.
      #
      # @return [Boolean]
      #
      def info?
        self.class.level <= ::Logger::INFO
      end

      #
      # Logs a message with the `warn` level.
      #
      # @param [String] message The message to log
      # @param [String, Symbol] prog_name The program name of the message
      #
      # @return [void]
      # @yield The message
      #
      def warn(...)
        write(::Logger::WARN, ...)
      end

      #
      # Returns true if the log level allows entries with severity Logger::WARN to be written, false otherwise.
      #
      # @return [Boolean]
      #
      def warn?
        self.class.level <= ::Logger::WARN
      end

      #
      # Logs a message with the `error` level.
      #
      # @param [String] message The message to log
      # @param [String, Symbol] prog_name The program name of the message
      #
      # @return [void]
      # @yield The message
      #
      def error(...)
        write(::Logger::ERROR, ...)
      end

      #
      # Returns true if the log level allows entries with severity Logger::ERROR to be written, false otherwise.
      #
      # @return [Boolean]
      #
      def error?
        self.class.level <= ::Logger::ERROR
      end

      #
      # Logs a message with the `fatal` level.
      #
      # @param [String] message The message to log
      # @param [String, Symbol] prog_name The program name of the message
      #
      # @return [void]
      # @yield The message
      #
      def fatal(...)
        write(::Logger::FATAL, ...)
      end

      #
      # Returns true if the log level allows entries with severity Logger::FATAL to be written, false otherwise.
      #
      # @return [Boolean]
      #
      def fatal?
        self.class.level <= ::Logger::FATAL
      end

      private

      #
      # Writes the message with the given level into all outputs.
      #
      # @param [Integer] severity The severity level of the message
      # @param [String] message The message to write
      # @param [String] prog_name The program name of the message
      #
      # @return [void]
      #
      def write(severity, message = nil, prog_name = nil, &)
        return if severity < self.class.level

        message ||= yield

        called_method = "#{@prog_name}##{caller_locations(2, 1).first.label}"
        prog_name ||= @prog_name.is_a?(Class) ? called_method : @prog_name

        @outputs.each do |output|
          output.write severity, prog_name, message
        end
      end
    end
  end
end
