# frozen_string_literal: true

module Bianci
  module USSD
    class Page
      attr_reader :session

      def initialize(session)
        @session = session
        @request = proc { "No request found" }
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
                "#{constant_name} is supposed to be defined to process #{menu_name} menu page #{page_number}"
        end

        session.menu = Bianci::USSD::Menu.new(menu_name)
        page.new(session).send(:request)
      end

      def method_missing(method_name, *args)
        name = method_name.to_s

        allowed_dynamic_methods_prefix_delegator = {
          "redirect_to_" => proc { delegate_redirected_to(name) },
          "render_and_" => proc { delegate_render_and(name, args) }
        }

        dynamic_method = allowed_dynamic_methods_prefix_delegator.find do |key, _value|
          name.start_with? key
        end

        return super unless dynamic_method.present?

        dynamic_method.second.call
      end

      def delegate_redirected_to(name)
        name.delete_prefix!("redirect_to_")

        case name
        when "next_page"
          page = self.class.name.split("::").last
          next_page_number = (page[-1].to_i + 1).to_s
          page[-1] = next_page_number

          load_page(page, session.menu.name)
        end
      end

      def delegate_render_and(name, args)
        name.delete_prefix!("render_and_")

        states = {
          "await" => :await,
          "end" => :end
        }

        render args.first, state: states[name]
      end
    end
  end
end
