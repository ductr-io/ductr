# frozen_string_literal: true

require "thor"

module Ductr
  module CLI
    #
    # The default CLI is started when no project folder was found.
    # It expose project and adapter generation tasks.
    #
    class Default < Thor
      desc "new", "Generates a new project"
      #
      # Generates a new project
      #
      # @param name [String] The project's name
      #
      # @return [void]
      #
      def new(name = nil)
        NewProjectGenerator.start([name])
      end
    end
  end
end
