module Ellen
  module Handlers
    class Cron < Base
      on(/add job "(.+)" (.+)/, name: "add", description: "Add a new cron job")

      on(/delete job (\d+)/, name: "delete", description: "Delete a cron job")

      on(/list jobs\z/, name: "list", description: "List all cron jobs")

      attr_writer :jobs

      def add(message)
        job = create(message)
        robot.say "Job #{job.id} created"
      end

      def delete(message)
        id = message[1].to_i
        if jobs.has_key?(id)
          jobs[id].stop
          jobs.delete(id)
          push
          robot.say "Job #{id} deleted"
        else
          robot.say "Job #{id} does not exist"
        end
      end

      def list(message)
        robot.say jobs_list
      end

      private

      def pull
        self.jobs = robot.brain.data["cron"].inject({}) do |result, (id, attributes)|
          result.merge(id => Ellen::Cron::Job.new(attributes))
        end
      end

      def push
        robot.brain.data["cron"] = jobs.inject({}) do |result, (id, job)|
          result.merge(id => job.to_json)
        end
        robot.brain.save
      end

      def jobs
        @jobs ||= {}
      end

      def create(message)
        job = Ellen::Cron::Job.new(id: generate_id, schedule: message[1], body: message[2])
        jobs[job.id] = job
        push
        job.start(robot)
        job
      end

      def jobs_list
        if jobs.empty?
          "Jobs not found"
        else
          jobs.values.map(&:description).join("\n")
        end
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
