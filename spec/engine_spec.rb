# frozen_string_literal: true

RSpec.describe Bianchi::USSD::Engine do
  context "validation" do
    it "raises argument error when invalid parameters are passed" do
      params = {}

      expect{ Bianchi::USSD::Engine.start(params) {}}.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::ArgumentError)
        expect(error.message).to eq "[\"session_id\", \"mobile_number\", \"input_body\", \"activity_state\"] required in params to start engine"
      end
    end

    it "raises page load error when initial menu isn't defined" do
      params = {
        mobile_number: "+233557711911",
        activity_state: "initial",
        session_id: "345344322123",
        input_body: ""
      }

      expect{ Bianchi::USSD::Engine.start(params) {}}.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::PageLoadError)
        expect(error.message).to eq "an initial menu is required to proceed"
      end
    end

    it "raises page load error when initial menu is created but page files cant be found" do
      params = {
        mobile_number: "+233557711911",
        activity_state: "initial",
        session_id: "345344322123",
        input_body: ""
      }

      expect{ Bianchi::USSD::Engine.start(params) { menu :main, initial: true} }.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::PageLoadError)
        expect(error.message).to eq "USSD::MainMenu::Page1 is supposed to be defined to process main menu Page1"
      end
    end
  end

end
