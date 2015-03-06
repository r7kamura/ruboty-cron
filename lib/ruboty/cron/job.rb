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

      def description
        %<%5s: "%s" %s> % [id, schedule, body]
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
    end
  end
end
