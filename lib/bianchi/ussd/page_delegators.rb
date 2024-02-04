# frozen_string_literal: true

# rubocop:disable Style/MissingRespondToMissing
module Bianchi
  module USSD
    module PageDelegators
      def method_missing(method_name, *args)
        name = method_name.to_s

        allowed_dynamic_methods_prefix_delegator = {
          "redirect_to_" => proc { delegate_redirected_to(name) },
          "render_and_" => proc { delegate_render_and(name, args) },
          "session_" => proc { delegate_session(name) }
        }

        dynamic_method = allowed_dynamic_methods_prefix_delegator.find do |key, _value|
          name.start_with? key
        end

        return super unless dynamic_method.present?

        dynamic_method.second.call
      end

      # redirect delegators
      def delegate_redirected_to(name)
        name.delete_prefix!("redirect_to_")
        page, menu_name = handle_redirect_to_cases(name)
        load_page(page, menu_name)
      end

      def handle_redirect_to_cases(name)
        redirect_to_method_names = [
          "next_page",
          "previous_page",
          "(menu_name)_menu_page_(number)"
        ]

        case name
        when /(next|previous)_page/
          to_next_or_previous_page Regexp.last_match(1)
        when /(.+)_menu_page_(\d+)/
          to_menu_page(Regexp.last_match(1), Regexp.last_match(2).to_i)
        else
          error_message = redirect_to_method_names.map { |method_name| "redirect_to_#{method_name}" }.join(", ")
          raise MethodNameError, "do you mean [#{error_message}]"
        end
      end

      def to_next_or_previous_page(keyword)
        page = self.class.name.split("::").last

        next_page_number = keyword == "next" ? (page[-1].to_i + 1) : (page[-1].to_i - 1)

        raise PageLoadError, "can not redirect to previous page from page 1" if next_page_number < 1

        [page_number(page, next_page_number), session.menu.name]
      end

      def page_number(page, next_page_number)
        page.length == 4 ? page << next_page_number.to_s : page[-1] = next_page_number.to_s

        page
      end

      def to_menu_page(menu_name, page_number)
        page = "Page#{page_number}"

        [page, menu_name]
      end

      # render delegators
      def delegate_render_and(name, args)
        name.delete_prefix!("render_and_")

        states = {
          "await" => :await,
          "end" => :end
        }

        unless states.keys.include? name
          raise MethodNameError, "do you mean [#{states.keys.map { |state| "render_and_#{state}" }.join(', ')}]"
        end

        render args.first, state: states[name]
      end

      # session_delegators
      def delegate_session(name)
        name.delete_prefix!("session_")

        allowed_session_instance_names = session.instance_variables.map { |variable| variable.to_s.delete_prefix("@") }

        unless allowed_session_instance_names.include? name
          error_message = allowed_session_instance_names.map { |method_name| "session_#{method_name}" }.join(", ")
          raise MethodNameError, "do you mean [#{error_message}]"
        end

        session.send(name)
      end
    end
  end
end
# rubocop:enable Style/MissingRespondToMissing
