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
              msisdn: params['msisdn'],
              msg_type: return_activity_state(params['msg_type']),
              ussd_bod: params['ussd_body'],
              nw_code: params['nw_code'],
              service_code: params['service_code']
            }
          end
  
          def appsnmobile_prompt_data_parser(prompt_data)
            prompt_data['msg_type'] == :await ? "CON #{prompt_data['body']}" : "END #{prompt_data['body']}"
          end

          def return_activity_state(msg_type)
            case msg_type
              when '0'
                'initial'
              when '1'
                'subsequent'
              when '2'
                'end'
              else
                raise ArgumentError, "#{@provider} sent in an unknown message type or msg_type"
            end
          end
        end
      end
    end
  end