# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength, Lint/EmptyBlock
RSpec.describe Bianchi::USSD::Engine do
  before :each do
    stub_const("ENV", ENV.to_hash.merge("REDIS_URL" => "redis://localhost:6379"))
  end

  def define_pages(methods = {})
    page_class = Class.new(Bianchi::USSD::Page) do
      methods.compact.each do |method_name, value_to_render|
        define_method method_name.to_sym do
          render_and_await value_to_render
        end
      end
    end

    stub_const "USSD::MainMenu::Page1", page_class
  end

  let(:correct_params) do
    {
      mobile_number: "+233557711911",
      activity_state: "initial",
      session_id: "345344322123",
      input_body: ""
    }
  end

  let(:menu) { Bianchi::USSD::Menu.new "main" }
  let(:session) do
    Bianchi::USSD::Session.new(correct_params).tap do |s|
      s.menu = menu
    end
  end

  let(:page) { Bianchi::USSD::Page.new session }

  context "validation" do
    it "raises argument error when invalid parameters are passed" do
      params = {}

      expect { Bianchi::USSD::Engine.start(params) {} }.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::ArgumentError)
        expect(error.message).to eq(
          "[\"session_id\", \"mobile_number\", \"input_body\", \"activity_state\"] required in params to start engine"
        )
      end
    end

    it "raises argument error when invalid options are passed" do
      expect { Bianchi::USSD::Engine.start(correct_params, wrong_option: :test) {} }.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::ArgumentError)
        expect(error.message).to eq(
          "[:provider] are the only valid option keys"
        )
      end
    end

    it "raises page load error when initial menu isn't defined" do
      expect { Bianchi::USSD::Engine.start(correct_params) {} }.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::PageLoadError)
        expect(error.message).to eq "an initial menu is required to proceed"
      end
    end

    it "raises page load error when initial menu is created but page files cant be found" do
      expect { Bianchi::USSD::Engine.start(correct_params) { menu :main, initial: true } }.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::PageLoadError)
        expect(error.message).to eq "USSD::MainMenu::Page1 is supposed to be defined to process main menu Page1"
      end
    end

    it "raises page load error when request or response is not defined on page" do
      define_pages(request: "testing request")

      expect { Bianchi::USSD::Engine.start(correct_params) { menu :main, initial: true } }.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::PageLoadError)
        expect(error.message).to eq "USSD::MainMenu::Page1 is supposed to have method response defined"
      end
    end
  end

  context "Operation" do
    it "renders an initial menu pages request" do
      define_pages(request: "testing request", response: "testing response")

      engine_object = Bianchi::USSD::Engine.start(correct_params) { menu :main, initial: true }
      expect(engine_object.prompt_data).to eq(
        {
          "activity_state" => :await,
          "body" => "testing request",
          "mobile_number" => "+233557711911",
          "session_id" => "345344322123",
          "input_body" => ""
        }
      )
    end
  end

  context "Providers africastalking" do
    let(:africastalking) do
      {
        "sessionId" => "345344322123",
        "serviceCode" => "*123#",
        "phoneNumber" => "+233557711911",
        "text" => ""
      }
    end

    it "parses params to meet africastalking docs" do
      define_pages(request: "test africastalking", response: "test africastalking response")

      engine_object = Bianchi::USSD::Engine.start(africastalking, provider: :africastalking) do
        menu :main, initial: true
      end
      expect(engine_object.prompt_data).to eq("CON test africastalking")
    end
  end

  context "Providers appsnmobile" do
    let(:appsnmobile_params) do
      {
        "session_id" => "345344322123",
        "msisdn" => "+233557711911",
        "msg_type" => "0",
        "ussd_body" => "",
        "nw_code" => nil,
        "service_code" => nil
      }
    end

    it "parses params to meet appsnmobile docs" do
      define_pages(request: "test africastalking", response: "test africastalking response")

      engine_object = Bianchi::USSD::Engine.start(appsnmobile_params, provider: :appsnmobile) do
        menu :main, initial: true
      end

      appsnmobile_params.merge!(
        "ussd_body" => "test africastalking",
        "msg_type" => "1"
      )

      expect(engine_object.prompt_data).to eq(appsnmobile_params.to_json)
    end
  end
end
# rubocop:enable Metrics/BlockLength, Lint/EmptyBlock
