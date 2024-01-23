# frozen_string_literal: true

module Bianchi
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
        unless left_required_params.empty?
          raise ArgumentError, "#{left_required_params} required in params to start engine"
        end

        return if %w[initial subsequent].include? params[:activity_state]

        raise ArgumentError, "activity_state has to either be initial or subsequent"
      end

      def menu(menu_name, options = {})
        unless [String, Symbol].include? menu_name.class
          raise ArgumentError, "menu_name expected to either be string/symbol to define menus"
        end

        raise ArgumentError, "menu_options expected to be a hash to start engine" unless options.is_a? Hash

        @menus << Menu.new(menu_name, options)
      end

      def ensure_initial_menu
        return if initial_menu

        raise PageLoadError, "an initial menu is required to proceed"
      end

      def process_activity_state
        ensure_initial_menu

        page = case session.activity_state.to_sym
               when :initial
                 initial_menu_page
               when :subsequent
                 subsequent_menu_page
               end

        @prompt_data = page.session_prompt_data
      end

      def initial_menu_page
        session.menu = initial_menu
        menu_page("Page1", :request)
      end

      def initial_menu
        menus.find { |menu| menu.options[:initial] }
      end

      def subsequent_menu_page
        previous_session = session.store.previous_session
        session.menu = previous_session.menu

        menu_page(previous_session.page_number, :response)
      end

      def menu_page(page_number, action)
        constant_name = "USSD::#{session.menu.name.camelize}Menu::#{page_number}"
        page = constant_name.safe_constantize

        unless page
          raise PageLoadError,
                "#{constant_name} is supposed to be defined to process #{session.menu.name} menu #{page_number}"
        end

        page.new(session).tap do |p|
          p.ensure_methods_defined(%i[request response])
          p.send(action)
        end
      end
    end
  end
end
