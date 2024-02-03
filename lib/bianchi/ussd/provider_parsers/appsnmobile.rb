module Bianchi
    module USSD
      module ProviderParsers
        module Appsnmobile
          def appsnmobile_params_parser(params)
            required_params = %w[session_id msisdn msg_type ussd_body nw_code service_code]
            left_required_params = required_params - params.keys.map(&:to_s)
  
            unless left_required_params.empty?
              raise ArgumentError, "#{left_required_params} required in params to start engine for provider #{@provider}"
            end
  
            {
              session_id: params['session_id'],
              mobile_number: params['msisdn'],
              activity_state: return_activity_state(params['msg_type']),
              input_body: params['ussd_body'],
              nw_code: params['nw_code'],
              service_code: params['service_code']
            }
          end
  
          def appsnmobile_prompt_data_parser(prompt_data)
            msg_type = prompt_data['activity_state'] == :await ? '1' : '2'

            {
              session_id: prompt_data['session_id'],
              msisdn: prompt_data['mobile_number'],
              msg_type: msg_type,
              ussd_body: prompt_data['body'],
              nw_code: prompt_data['nw_code'],
              service_code: prompt_data['service_code']
            }.to_json
          end

          def return_activity_state(msg_type)
            case msg_type
              when '0'
                'initial'
              when '1'
                'subsequent'
              else
                raise ArgumentError, "#{@provider} sent in an unknown message type or msg_type"
            end
          end
        end
      end
    end
  end