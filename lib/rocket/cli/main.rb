# frozen_string_literal: true

require "thor"

module Rocket
  module CLI
    #
    # The main CLI is started when used inside a rocket project folder.
    # It exposes scheduling and monitoring tasks.
    #
    class Main < Thor
      # desc "start, s", "Start the server"
      # def start
      #   say "use Ctrl-C to stop"

      #   trap "SIGINT" do
      #     say "Exiting"
      #     exit 130
      #   end

      #   sleep
      # end

      desc "perform, p [JOB]", "Queues the given job"
      method_option :sync, type: :boolean, default: false, aliases: "-s",
                           desc: "Runs the job synchronously instead of queueing it"
      method_option :params, type: :array, aliases: "-p", desc: "Running the job with parameters"
      def perform(job_name)
        job = job_name.camelize.constantize.new(*options[:params])

        StoreHelper.track_job(job)
        return job.perform_now if options[:sync]

        job.enqueue
        return unless ActiveJob::Base.queue_adapter.is_a? ActiveJob::QueueAdapters::AsyncAdapter

        sleep(0.1) until StoreHelper.all_jobs_done?
      end
    end
  end
end
