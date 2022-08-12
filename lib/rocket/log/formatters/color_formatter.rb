# frozen_string_literal: true

require "logger"

module Rocket
  module Log
    #
    # A log formatter which colorize the text with ANSI colors.
    #
    class ColorFormatter < ::Logger::Formatter
      #
      # Colores the given log entry.
      #
      # @param [Integer] level The log's severity level
      # @param [Time] time The log's timestamp
      # @param [Symbol] prog_name The log's "program" name, used to add job method name to the log
      # @param [String] message The log's message
      #
      # @return [String] The formatted log
      #
      def call(level, time, prog_name, message)
        format(
          "#{c(:gray, "%s, [%s #%d]")} #{c(level, "%5s")} -- #{c(:blue, "%s:")} %s\n",
          level[0], format_datetime(time), Process.pid, level, prog_name, msg2str(message)
        )
      end

      private

      #
      # Colores a string based on the given color name or log level.
      #
      # @param [String, Symbol] name The desired color name
      # @param [String] str The string to colorize
      #
      # @return [String] The colorized string
      #
      def c(name, str)
        colors = { "DEBUG" => 32, "INFO" => 36, "WARN" => 33, "ERROR" => 31, "FATAL" => 41, gray: 90, blue: 34 }

        "\033[#{colors[name]}m#{str}\033[0m"
      end
    end
  end
end
