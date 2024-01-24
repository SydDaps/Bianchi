# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Bianchi::USSD::Engine do
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
      stub_const "USSD::MainMenu::Page1", instance_double("USSD::MainMenu::Page1", new: page)
      allow(page).to receive(:request).and_return(page.render_and_end("test_page"))

      expect { Bianchi::USSD::Engine.start(correct_params) { menu :main, initial: true } }.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::PageLoadError)
        expect(error.message).to eq "Bianchi::USSD::Page is supposed to have method response defined"
      end
    end
  end

  context "Operation" do
    it "renders an initial menu pages request" do
      stub_const "USSD::MainMenu::Page1", instance_double("USSD::MainMenu::Page1", new: page)
      allow(page).to receive(:response).and_return(page.render_and_end("test"))
      allow(page).to receive(:request).and_return(page.render_and_await("test"))

      engine_object = Bianchi::USSD::Engine.start(correct_params) { menu :main, initial: true }
      expect(engine_object.prompt_data).to eq(
        {
          "activity_state" => :await,
          "body" => "test",
          "mobile_number" => "+233557711911",
          "session_id" => "345344322123"
        }
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
