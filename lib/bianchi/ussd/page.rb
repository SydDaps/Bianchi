# frozen_string_literal: true

module Bianchi
  module USSD
    class Page
      attr_reader :session

      include USSD::PageDelegators

      def initialize(session)
        @session = session
      end

      def render(body, options = {})
        raise ArgumentError, "render body expected to be a string" unless body.is_a? String

        session.tap do |s|
          s.prompt_data = s.params.slice(:mobile_number, :session_id).merge(
            { activity_state: options[:state], body: body }
          )

          s.page_number = self.class.name.split("::").last
          s.store.track_session
        end
      end

      def load_page(page_number, menu_name)
        constant_name = "USSD::#{menu_name.camelize}Menu::#{page_number}"
        page = constant_name.safe_constantize

        unless page
          raise PageLoadError,
                "#{constant_name} is supposed to be defined to process #{menu_name} menu #{page_number}"
        end

        session.menu = Menu.new(menu_name)
        page.new(session).send(:request)
      end
    end
  end
end
