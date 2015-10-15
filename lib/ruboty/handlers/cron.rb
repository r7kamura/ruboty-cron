module Ruboty
  module Handlers
    class Cron < Base
      NAMESPACE = "cron"

      on(/add job "(?<schedule>.+?)" (?<body>.+)/m, name: "add", description: "Add a new cron job")

      on(/delete job (?<id>\d+)/, name: "delete", description: "Delete a cron job")

      on(/list jobs\z/, name: "list", description: "List all cron jobs")

      on(/suspend job (?<id>\d+)/, name: "suspend", description: "Suspend a cron job")

      on(/resume job (?<id>\d+)/, name: "resume", description: "Resume a cron job")

      attr_writer :jobs

      def initialize(*args)
        super
        remember
      end

      def add(message)
        job = create(message)
        message.reply("Job #{job.id} created")
      end

      def delete(message)
        id = message[:id].to_i
        if jobs.has_key?(id)
          jobs.delete(id)
          running_jobs[id].stop
          running_jobs.delete(id)
          message.reply("Job #{id} deleted")
        else
          message.reply("Job #{id} does not exist")
        end
      end

      def list(message)
        message.reply(summary, code: true)
      end

      def suspend(message)
        id = message[:id].to_i
        if jobs.has_key?(id)
          if running_jobs[id]
            running_jobs[id].suspend
            jobs[id] = running_jobs[id].to_hash
            running_jobs.delete(id)
            message.reply("Job #{id} suspended")
          else
            message.reply("Job #{id} had suspended")
          end
        else
          message.reply("Job #{id} does not exist")
        end
      end

      def resume(message)
        id = message[:id].to_i
        if jobs.has_key?(id)
          job = Ruboty::Cron::Job.new(jobs[id])
          if job.suspended?
            job.resume(robot)
            jobs[id] = job.to_hash
            running_jobs[id] = job
            message.reply("Job #{id} resumed")
          else
            message.reply("Job #{id} is running")
          end
        else
          message.reply("Job #{id} does not exist")
        end
      end

      private

      def remember
        jobs.each do |id, attributes|
          job = Ruboty::Cron::Job.new(attributes)
          unless job.suspended?
            running_jobs[id] = job
            job.start(robot)
          end
        end
      end

      def jobs
        robot.brain.data[NAMESPACE] ||= {}
      end

      def create(message)
        job = Ruboty::Cron::Job.new(
          message.original.except(:robot).merge(
            body: message[:body],
            id: generate_id,
            schedule: message[:schedule],
          ),
        )
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
          Ruboty::Cron::Job.new(attributes).description
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
