# frozen_string_literal: true

module Bianci
  module USSD
    class Engine
      attr_accessor :params, :session, :menus, :prompt_data

      def initialize(params)
        @session = Session.new(params)
        @menus = []
        @prompt_data = nil
      end

      def self.start(params, &block)
        raise ArgumentError, "block required to start the engine" unless block_given?

        validate_start_params(params)

        engine = new(params)

        engine.tap do |e|
          e.instance_eval(&block)
          e.process_activity_state
        end
      end

      def self.validate_start_params(params)
        raise ArgumentError, "params expected to be a hash to start engine" unless params.is_a? Hash

        required_params = %w[session_id mobile_number input_body activity_state]

        left_required_params = required_params - params.keys.map(&:to_s)
        return if left_required_params.empty?

        raise ArgumentError, "#{left_required_params} required in params to start engine"
      end

      def menu(menu_name, options = {})
        unless [String, Symbol].include? menu_name.class
          raise ArgumentError, "menu_name expected to either be string/symbol to define menus"
        end

        unless options.is_a? Hash
          raise ArgumentError,
                "menu_options expected to be a hash to start engine"
        end

        @menus << Menu.new(menu_name, options)
      end

      def process_activity_state
        case session.activity_state.to_sym
        when :initial
          initial_page
        when :subsequent
          subsequent_page
        end
      end

      def initial_page
        initial_menu = menus.find { |menu| menu.options[:initial] }
        render_menu_page(initial_menu, "Page1", :request)
      end

      def subsequent_page
        previous_session = session.store.previous_session
        render_menu_page(previous_session.menu, previous_session.page_number, :response)
      end

      def render_menu_page(menu_object, page_number, action)
        constant_name = "USSD::#{menu_object.name.camelize}Menu::#{page_number}"
        page = constant_name.safe_constantize

        unless page
          raise PageLoadError,
                "#{constant_name} is supposed to be defined to process #{menu_object.name} menu #{page_number}"
        end

        session.menu = menu_object
        @prompt_data = page.new(session).send(action).prompt_data
      end
    end
  end
end
