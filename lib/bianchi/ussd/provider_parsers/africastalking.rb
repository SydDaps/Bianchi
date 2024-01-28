module Bianchi
  module USSD
    module ProviderParsers
      module Africastalking
        def africastalking_params_parser(params)
          required_params = %w[sessionId phoneNumber text serviceCode]
          left_required_params = required_params - params.keys.map(&:to_s)

          unless left_required_params.empty?
            raise ArgumentError, "#{left_required_params} required in params to start engine for provider #{@provider}"
          end

          {
            session_id: params["sessionId"],
            mobile_number: params["phoneNumber"],
            activity_state: params["text"] && params["text"].empty? ? "initial" : "subsequent",
            input_body: params["text"].split("*").last,
            service_code: params["serviceCode"]
          }
        end

        def africastalking_prompt_data_parser(prompt_data)
          prompt_data["activity_state"] == :await ? "CON #{prompt_data['body']}" : "END #{prompt_data['body']}"
        end
      end
    end
  end
end