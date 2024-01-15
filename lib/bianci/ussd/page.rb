# frozen_string_literal: true

module Bianci
  module USSD
    class Page
      attr_reader :session

      def initialize(session)
        @session = session
      end

      def render_and_await(body)
        session.tap do |s|
          s.prompt_data = s.params.slice(:mobile_number, :session_id).merge(
            { activity_state: :subsequent, body: body }
          )

          s.page_number = self.class.name.split("::").last
          s.store.track_session
        end
      end

      def method_missing(name, *args)
        name = name.to_s
        return super unless name.start_with? "redirect_to"

        name.delete_prefix!("redirect_to_")

        case name
        when "next_page"
          page = self.class.name.split("::").last
          next_page_number = (page[-1].to_i + 1).to_s
          page[-1] = next_page_number

          load_page(page, session.menu.name)
        end
      end

      def load_page(page_number, menu_name)
        constant_name = "USSD::#{menu_name.camelize}Menu::#{page_number}"
        page = constant_name.safe_constantize

        unless page
          raise "PageLoadError: #{constant_name} is supposed to be defined to process #{menu_name} menu page #{page_number}"
        end

        session.menu = Bianci::USSD::Menu.new(menu_name)
        page.new(session).send(:request)
      end
    end
  end
end
