require "active_support/core_ext/hash/keys"
require "json"

module Ellen
  module Cron
    class Job
      attr_reader :attributes

      def initialize(attributes)
        @attributes = attributes.stringify_keys
      end

      def to_json
        to_hash.to_json
      end

      # TODO
      def start
        puts "start #{self}"
      end

      # TODO
      def stop
        puts "stop #{self}"
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

      private

      def to_hash
        attributes.to_json
      end
    end
  end
end
