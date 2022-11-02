# frozen_string_literal: true

require_relative "lib/ductr/version"

Gem::Specification.new do |spec|
  spec.name = "ductr"
  spec.version = Ductr::VERSION
  spec.authors = ["Mathieu Morel"]
  spec.email = ["mathieu@lamanufacture.dev"]

  spec.summary = "Data pipeline and ETL framework."
  spec.description = "A data pipeline and ETL framework for ruby."
  # TODO: Change homepage for a real one
  spec.homepage = "https://ductr.example.com"
  spec.required_ruby_version = ">= 3.1.0"
  # TODO: Change gem server URL for a real one
  spec.metadata["allowed_push_host"] = "https://example.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"
  # TODO: Change gem's public repo URL for a real one
  spec.metadata["source_code_uri"] = "https://git.example.com/ductr"
  # TODO: Change gem's changelog URL for a real one
  spec.metadata["changelog_uri"] = "https://git.example.com/ductr"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis)|appveyor)})
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "debug", "~> 1.6"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "yard", "~> 0.9"

  spec.add_dependency "activejob", "~> 7.0"
  spec.add_dependency "colorize", "~> 0.8"
  spec.add_dependency "kiba", "~> 4.0"
  spec.add_dependency "rufus-scheduler", "~> 3.8"
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "zeitwerk", "~> 2.6"
end
