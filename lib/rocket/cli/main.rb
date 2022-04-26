# frozen_string_literal: true

require "thor"

module Rocket
  module CLI
    #
    # The default CLI is started when no project folder was found.
    # It expose project and adapter generation tasks.
    #
    class Main < Thor
      desc "start, s", "Start the server"
      #
      # Starts the server
      #
      # @return [void]
      #
      def start
        say "use Ctrl-C to stop"

        trap "SIGINT" do
          say "Exiting"
          exit 130
        end

        sleep
      end
    end
  end
end
