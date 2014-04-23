module Ellen
  module Handlers
    class Cron < Base
      NAMESPACE = "cron"

      on(/add job "(.+)" (.+)/, name: "add", description: "Add a new cron job")

      on(/delete job (\d+)/, name: "delete", description: "Delete a cron job")

      on(/list jobs\z/, name: "list", description: "List all cron jobs")

      attr_writer :jobs

      def initialize(*args)
        super
        remember
      end

      def add(message)
        job = create(message)
        robot.say("Job #{job.id} created")
      end

      def delete(message)
        id = message[1].to_i
        if jobs.has_key?(id)
          jobs.delete(id)
          running_jobs[id].stop
          running_jobs.delete(id)
          robot.say("Job #{id} deleted")
        else
          robot.say("Job #{id} does not exist")
        end
      end

      def list(message)
        robot.say(summary)
      end

      private

      def remember
        jobs.each do |id, attributes|
          job = Ellen::Cron::Job.new(attributes)
          running_jobs[id] = job
          job.start(robot)
        end
      end

      def jobs
        robot.brain.data[NAMESPACE] ||= {}
      end

      def create(message)
        job = Ellen::Cron::Job.new(id: generate_id, schedule: message[1], body: message[2])
        jobs[job.id] = job.to_hash
        job.start(robot)
        running_jobs[job.id] = job
        job
      end

      def summary
        if jobs.empty?
          empty_message
        else
          job_descriptions
        end
      end

      def empty_message
        "Job not found"
      end

      def job_descriptions
        jobs.values.map do |attributes|
          Ellen::Cron::Job.new(attributes).description
        end.join("\n")
      end

      def generate_id
        loop do
          id = rand(10000)
          break id unless jobs.has_key?(id)
        end
      end

      def running_jobs
        @running_jobs ||= {}
      end
    end
  end
end
