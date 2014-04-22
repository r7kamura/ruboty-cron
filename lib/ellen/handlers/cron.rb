module Ellen
  module Handlers
    class Cron < Base
      NAMESPACE = "cron"

      on(/add job "(.+)" (.+)/, name: "add", description: "Add a new cron job")

      on(/delete job (\d+)/, name: "delete", description: "Delete a cron job")

      on(/list jobs\z/, name: "list", description: "List all cron jobs")

      attr_writer :jobs

      def add(message)
        job = create(message)
        robot.say("Job #{job.id} created")
      end

      def delete(message)
        id = message[1].to_i
        if jobs.has_key?(id)
          jobs[id].stop
          jobs.delete(id)
          robot.say("Job #{id} deleted")
        else
          robot.say("Job #{id} does not exist")
        end
      end

      def list(message)
        robot.say(summary)
      end

      private

      def jobs
        robot.brain.data[NAMESPACE] ||= {}
      end

      def create(message)
        job = Ellen::Cron::Job.new(id: generate_id, schedule: message[1], body: message[2])
        jobs[job.id] = job.to_hash
        job.start(robot)
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
    end
  end
end
