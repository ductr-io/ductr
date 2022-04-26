# frozen_string_literal: true

require "thor"
require "thor/group"

module Rocket
  module CLI
    #
    # Thor generator to create a new project
    #
    class NewProjectGenerator < Thor::Group
      include Thor::Actions
      desc "Generate a new project"
      argument :name, type: :string, optional: true, default: ""

      #
      # The templates source used to create a new project
      #
      # @return [String] the templates source absolute path
      #
      def self.source_root
        "#{__dir__}/templates/project"
      end

      #
      # Doing some setup before generating file,
      # creates the project directory and sets it as destination for the generator
      #
      # @return [void]
      #
      def init
        empty_directory name
        self.destination_root = "#{destination_root}/#{name}"
      end

      #
      # Creates files in the project's root
      #
      # @return [void]
      #
      def gen_root
        copy_file "gemfile.rb", "Gemfile"
        copy_file "rubocop.yml", ".rubocop.yml"
        copy_file "tool-versions", ".tool-versions"
      end

      #
      # Creates the bin file for the project
      #
      # @return [void]
      #
      def gen_bin
        copy_file "bin_rocket.rb", "bin/rocket"
      end

      #
      # Creates files in the `config` folder
      #
      # @return [void]
      #
      def gen_config
        copy_file "config_app.rb", "config/app.rb"
        copy_file "config_development.yml", "config/development.yml"
        copy_file "config_environment_development.rb", "config/environment/development.rb"
      end
    end
  end
end