module Ruboty
  module Cron
    class Job
      attr_reader :attributes, :thread

      def initialize(attributes)
        @attributes = attributes.stringify_keys
      end

      def start(robot)
        @thread = Thread.new do
          Chrono::Trigger.new(schedule) do
            robot.receive(
              attributes.symbolize_keys.except(
                :id,
                :schedule,
              ),
            )
          end.run
        end
      end

      def to_hash
        attributes
      end

      def stop
        thread.kill
      end

      def suspend
        stop
        attributes["suspended"] = true
      end

      def resume(robot)
        start(robot)
        attributes.delete("suspended") if attributes.has_key?("suspended")
      end

      def description
        %<%5s: (%s) "%s" %s> % [id, suspended? ? "suspended" : "active", schedule, body]
      end

      def id
        attributes["id"]
      end

      def schedule
        attributes["schedule"]
      end

      def body
        attributes["body"]
      end

      def suspended?
        !!attributes["suspended"]
      end
    end
  end
end
