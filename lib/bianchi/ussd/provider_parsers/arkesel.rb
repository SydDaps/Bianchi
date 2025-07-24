module Bianchi
  module USSD
    module ProviderParsers
      module Arkesel
        def arkesel_params_parser(params)
          {
            session_id: params["sessionID"],
            mobile_number: params["msisdn"],
            activity_state: params["newSession"] ? "initial" : "subsequent",
            input_body: params["userData"],
            service_code: params["userID"]
          }
        end

        def arkesel_prompt_data_parser(prompt_data)
          {
            sessionID: prompt_data["session_id"],
            userID: prompt_data["service_code"],
            msisdn: prompt_data["mobile_number"],
            message: prompt_data["body"],
            continueSession: prompt_data["activity_state"] == :await ? "true" : "false"
          }
        end
      end
    end
  end
end
