# frozen_string_literal: true

module Bianci
  module USSD
    class Store
      attr_reader :session, :data

      def initialize(session)
        @redis = Redis.new(url: ENV.fetch("REDIS_URL", nil))
        @data = data
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

        menu = Bianci::USSD::Menu.new(previous_activity_data[:menu])
        page_number = previous_activity_data[:page_number]
        Bianci::USSD::Session.new(previous_activity_data, menu, page_number)
      end
    end
  end
end
