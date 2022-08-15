# frozen_string_literal: true

require "logger"
require "colorized_string"

module Rocket
  module Log
    #
    # A log formatter which colorize the text with ANSI colors.
    #
    class ColorFormatter < ::Logger::Formatter
      #
      # Colorizes the given log entry.
      #
      # @param [Integer] level The log's severity level
      # @param [Time] time The log's timestamp
      # @param [Symbol] prog_name The log's "program" name, used to add job method name to the log
      # @param [String] message The log's message
      #
      # @return [String] The formatted log
      #
      def call(level, time, prog_name, message)
        format(format_str(level), level[0], format_datetime(time), Process.pid, level, prog_name, msg2str(message))
      end

      private

      #
      # Generates the colorized format string based on the log level.
      #
      # @param [String] level The log level
      #
      # @return [String] The colored format string
      #
      def format_str(level)
        colors = {
          "DEBUG" => :green, "INFO" => :cyan, "WARN" => :yellow, "ERROR" => :red, "FATAL" => { background: :red }
        }

        timestamp = ColorizedString["%s, [%s #%d]"].colorize(:light_black)
        level_name = ColorizedString["%5s"].colorize(colors[level])
        prog_name = ColorizedString["%s:"].colorize(:blue)

        "#{timestamp} #{level_name} -- #{prog_name} %s\n"
      end
    end
  end
end
