# frozen_string_literal: true

module Bianchi
  module USSD
    module ProviderConfigurations
      def parse_params(params)
        provider_parsers = {
          none: proc { params },
          africa_is_talking: proc { africa_is_talking_params_parser(params) }
        }.with_indifferent_access

        parser = provider_parsers[@provider]

        raise ProviderError, "Could not find configurations for provider(#{@provider}) specified" unless parser.present?

        parser.call
      end

      def africa_is_talking_params_parser(params)
        required_params = %w[sessionId phoneNumber text serviceCode]
        left_required_params = required_params - params.keys.map(&:to_s)

        unless left_required_params.empty?
          raise ArgumentError, "#{left_required_params} required in params to start engine for provider #{@provider}"
        end

        {
          session_id: params["sessionId"],
          mobile_number: params["phoneNumber"],
          activity_state: params["text"] && params["text"].empty? ? "initial" : "subsequent",
          input_body: params["text"],
          service_code: params["serviceCode"]
        }
      end

      def parser_prompt_data(prompt_data)
        provider_parsers = {
          none: proc { prompt_data },
          africa_is_talking: proc { africa_is_talking_prompt_data_parser(prompt_data) }
        }.with_indifferent_access

        parser = provider_parsers[@provider]

        raise StandardError, "could not parse response data for the provider specified." unless parser.present?

        parser.call
      end

      def africa_is_talking_prompt_data_parser(prompt_data)
        prompt_data["activity_state"] == :await ? "CON #{prompt_data['body']}" : "END #{prompt_data['body']}"
      end
    end
  end
end
