# frozen_string_literal: true

require "thor"

module Ductr
  module CLI
    #
    # The main CLI is started when used inside a ductr project folder.
    # It exposes scheduling and monitoring tasks.
    #
    class Main < Thor
      desc "perform, p [JOB]", "Queues the given job"
      method_option :sync, type: :boolean, default: false, aliases: "-s",
                           desc: "Runs the job synchronously instead of queueing it"
      method_option :params, type: :array, aliases: "-p", desc: "Running the job with parameters"
      def perform(job_name)
        job = job_name.camelize.constantize.new(*options[:params])

        job.is_a?(Pipeline) ? Store.register_pipeline(job) : Store.register_job(job)
        return job.perform_now if options[:sync]

        job.enqueue
        return unless ActiveJob::Base.queue_adapter.is_a? ActiveJob::QueueAdapters::AsyncAdapter

        sleep(0.1) until Store.all_done?
      end

      desc "schedule, s [SCHEDULERS]", "Run the given schedulers"
      def schedule(*scheduler_names)
        raise ArgumentError, "You must pass at least one scheduler name" if scheduler_names.empty?

        scheduler_names.each { |name| name.camelize.constantize.new }
        Scheduler.start

        sleep_until_interrupt do
          Scheduler.stop
        end
      end

      private

      #
      # Keeps the thread alive until Ctrl-C is pressed.
      #
      # @yield The block to execute when Ctrl-C is pressed
      #
      # @return [void]
      #
      def sleep_until_interrupt(&)
        say "use Ctrl-C to stop"

        trap "SIGINT" do
          say "Exiting"
          yield
          exit 130
        end

        sleep
      end
    end
  end
end
