module USSD
  class Engine
    def self.start(params)

      Bianchi::USSD::Engine.start(params, provider: :africa_is_talking) do
        # e.g menu :main, options
      end
    end
  end
end
