module USSD
  class Engine
    def self.start(params)

      Bianchi::USSD::Engine.start(params) do
        #menu :main, options


      end
    end
  end
end
