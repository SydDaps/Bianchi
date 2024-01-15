# frozen_string_literal: true

module Bianci
  module USSD
    class Engine
      attr_accessor :params, :session, :menus, :prompt_data

      def initialize(params)
        @session = Bianci::USSD::Session.new(params)
        @menus = []
        @prompt_data = nil
      end

      def self.start(params, &block)
        engine = new(params)

        engine.tap do |e|
          e.instance_eval(&block)
          e.process_activity_state
        end
      end

      def menu(menu_name, options = {})
        @menus << Bianci::USSD::Menu.new(menu_name, options)
      end

      def process_activity_state
        case session.activity_state.to_sym
        when :initial
          initial_menu = menus.find { |menu| menu.options[:initial] }
          render_menu_page(initial_menu, "Page1", :request)
        when :subsequent
          previous_session = session.store.previous_session
          render_menu_page(previous_session.menu, previous_session.page_number, :response)
        end
      end

      def render_menu_page(menu_object, page_number, action)
        constant_name = "USSD::#{menu_object.name.camelize}Menu::#{page_number}"
        page = constant_name.safe_constantize

        unless page
          raise "PageLoadError: #{constant_name} is supposed to be defined to process #{menu_object.name} menu page #{page_number}"
        end

        session.menu = menu_object
        @prompt_data = page.new(session).send(action).prompt_data
      end
    end
  end
end
