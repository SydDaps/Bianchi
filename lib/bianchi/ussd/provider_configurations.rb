# frozen_string_literal: true

module Bianchi
  module USSD
    module ProviderConfigurations
      include ProviderParsers::Africastalking
      include ProviderParsers::Appsnmobile

      def parse_params(params)
        provider_parsers = {
          none: proc { params },
          africastalking: proc { africastalking_params_parser(params) },
          appsnmobile: proc { appsnmobile_params_parser(params) }
        }.with_indifferent_access

        parser = provider_parsers[@provider]

        raise ProviderError, "Could not find configurations for provider(#{@provider}) specified" unless parser.present?

        parser.call
      end

      def parser_prompt_data(prompt_data)
        provider_parsers = {
          none: proc { prompt_data },
          africastalking: proc { africastalking_prompt_data_parser(prompt_data) },
          appsnmobile: proc { appsnmobile_prompt_data_parser(prompt_data) }
        }.with_indifferent_access

        parser = provider_parsers[@provider]

        raise StandardError, "could not parse response data for the provider specified." unless parser.present?

        parser.call
      end
    end
  end
end
