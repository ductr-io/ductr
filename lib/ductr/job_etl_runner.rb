# frozen_string_literal: true

module Ductr
  #
  # Allowing a job to execute ETL runners.
  # You need to declare the ETL_RUNNER_CLASS constant in the including class:
  #
  #   class CustomJobClass < Job
  #     ETL_RUNNER_CLASS = ETL::KibaRunner
  #     include JobETLRunner
  #   end
  #
  # The job must have the #parse_annotations method defined, which can be added by including ETL::Parser.
  #
  module JobETLRunner
    #
    # Parse job's annotations and create the runner instance.
    #
    def initialize(...)
      super(...)

      @runner = self.class::ETL_RUNNER_CLASS.new(*parse_annotations)
    end

    #
    # Opens adapters, executes the runner and then closes back adapters.
    #
    # @return [void]
    #
    def run
      adapters.each(&:open!)
      @runner.run
    ensure
      adapters.each(&:close!)
    end
  end
end
