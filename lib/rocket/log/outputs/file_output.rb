# frozen_string_literal: true

require "fileutils"

module Rocket
  module Log
    #
    # An output to write logs in a file
    #
    class FileOutput < StandardOutput
      #
      # Creates the output with the given formatter, path and options
      #
      # @param [::Logger::Formatter] formatter The formatter to use when writing logs
      # @param [String] path The path to write the logs
      # @param [Hash] **options The options to write files
      #
      # @see The ruby's logger documentation to get options documentation
      #
      def initialize(formatter, path:, **options) # rubocop:disable Lint/MissingSuper
        dir = File.dirname(path)
        FileUtils.mkdir_p(dir) unless File.directory?(dir)
        File.new(path, "w") unless File.exist?(path)

        @formatter = formatter.new
        @log_device = ::Logger::LogDevice.new path, **options
      end
    end
  end
end
