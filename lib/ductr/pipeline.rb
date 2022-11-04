# frozen_string_literal: true

module Ductr
  #
  # Pipelines allows to easily declare rich data pipelines.
  #
  # By using the `after` annotation, you can define steps execution hierarchy.
  #
  # `sync` and `async` are useful to define job sequences inside step methods.
  #
  # `Pipeline` inherits from `Job` which means that pipeline are enqueued as any other job.
  # Pipelines are enqueued in the :ductr_pipelines queue.
  #
  #   class MyPipeline < Ductr::Pipeline
  #     def first_step
  #       sync(MyJob, 1)
  #       async(SomeJob) # Executed when `MyJob` is done
  #     end
  #
  #     after :first_step
  #     def first_parallel_step # Returns when all three `HelloJob` are done
  #       async(HelloJob, :one)
  #       async(HelloJob, :two)
  #       async(HelloJob, :three)
  #     end
  #
  #     after :first_step
  #     def second_parallel_step # Executed concurrently with :first_parallel_step
  #       async(SomeJob)
  #       async(SomeOtherJob)
  #       sync(HelloJob, :one) # Executed when `SomeJob` and `SomeOtherJob` are done
  #     end
  #
  #     after :first_parallel_step, :second_parallel_step
  #     def last_step # Executed when `first_parallel_step` and `second_parallel_step` jobs are done
  #       sync(ByeJob)
  #     end
  #   end
  #
  # You can define pipelines with only one step by using `after` annotation without parameter:
  #
  #   class MonoStepPipeline < Ductr::Pipeline
  #     after
  #     def unique_step
  #       async(MyJob)
  #       async(MyJob)
  #     end
  #   end
  #
  # A pipeline can inherit from another, allowing you to overload and add steps to the parent pipeline:
  #
  #   class InheritPipeline < MonoStepPipeline
  #     after :unique_step
  #     def not_that_unique
  #       async(MyJob)
  #     end
  #   end
  #
  class Pipeline < Job
    #
    # @!method self.after
    #   Annotation to define preceding steps on a pipeline step method.
    #   @params *step_names [Array<Symbol>] The preceding steps methods names
    #   @example
    #     after :some_step_method, :some_other_step_method
    #     def my_step
    #       # ...
    #     end
    #
    #   @return [void]
    #
    annotable :after

    queue_as :ductr_pipelines

    # @return [PipelineRunner] The pipeline's runner instance
    attr_reader :runner

    #
    # @!method run
    #   Starts the pipeline runner.
    #   @return [void]
    #
    def_delegators :@runner, :run

    #
    # Initializes the pipeline runner
    #
    def initialize(...)
      super(...)

      @runner = PipelineRunner.new(self)
    end

    #
    # Puts the given job in the queue and waits for it to be done.
    #
    # @param [Class<Job>] job_class The job to enqueue
    # @param [Array<Object>] *params The job's params
    #
    # @return [void]
    #
    def sync(job_class, *params)
      @runner.current_step.flush_jobs
      @runner.current_step.enqueue_job job_class.new(*params)
      @runner.current_step.flush_jobs
    end

    #
    # Enqueues the given job.
    #
    # @param [Class<Job>] job_class The job to enqueue
    # @param [Array<Object>] *params The job's params
    #
    # @return [void]
    #
    def async(job_class, *params)
      @runner.current_step.enqueue_job job_class.new(*params)
    end

    #
    # Writes the pipeline's status into the Ductr's store.
    #
    # @param [Symbol] status The status of the job
    #
    # @return [void]
    #
    def status=(status)
      @status = status
      Store.write_pipeline(self)
    end
  end
end
