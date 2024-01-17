# frozen_string_literal: true

module Bianchi
  module USSD
    class Store
      attr_reader :session

      def initialize(session)
        @redis = Redis.new(url: ENV.fetch("REDIS_URL", nil))
        @session = session
      end

      def track_session
        data = {
          params: session.params,
          menu: session.menu.name,
          page_number: session.page_number
        }.to_json

        @redis.hset("#{session.id}-#{session.mobile_number}-activity", data: data)
      end

      def previous_session
        previous_activity = @redis.hgetall("#{session.id}-#{session.mobile_number}-activity")
        previous_activity_data = JSON.parse(previous_activity["data"]).with_indifferent_access

        menu = Menu.new(previous_activity_data[:menu])
        page_number = previous_activity_data[:page_number]
        Session.new(previous_activity_data, menu, page_number)
      end

      def get(key)
        parse_value @redis.hget("#{session.id}-#{session.mobile_number}-store", key)
      end

      def all
        parse_values @redis.hgetall("#{session.id}-#{session.mobile_number}-store")
      end

      def set(key, value)
        @redis.hset("#{session.id}-#{session.mobile_number}-store", { key => value.to_json })
      end

      def parse_values(data)
        data.transform_values { |v| parse_value v }
      end

      def parse_value(value)
        JSON.parse(value)
      rescue StandardError
        value
      end
    end
  end
end
