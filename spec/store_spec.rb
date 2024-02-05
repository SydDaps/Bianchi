# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Bianchi::USSD::Page do
  before :each do
    stub_const("ENV", ENV.to_hash.merge("REDIS_URL" => "redis://localhost:6379"))
  end

  let(:initial_params) do
    {
      mobile_number: "+233557711911",
      activity_state: "initial",
      session_id: "345344322123",
      input_body: ""
    }
  end

  let(:subsequent_params) do
    {
      mobile_number: "+233557711911",
      activity_state: "subsequent",
      session_id: "345344322123",
      input_body: "test"
    }
  end

  let(:menu) { Bianchi::USSD::Menu.new "main" }
  let(:initial_session) do
    Bianchi::USSD::Session.new(initial_params).tap do |s|
      s.menu = menu
    end
  end

  let(:subsequent_session) do
    Bianchi::USSD::Session.new(subsequent_params).tap do |s|
      s.menu = menu
    end
  end

  let(:page) { Bianchi::USSD::Page.new session }

  context "tracker" do
    it "should track retrieve session activity" do
      initial_session.store.track_session

      expect(subsequent_session.store.previous_session.params).to eq initial_session.params
      expect(subsequent_session.store.previous_session.menu.name).to eq initial_session.menu.name
    end
  end

  context "cache" do
    it "should set and get values on a session" do
      initial_session.store.set("selection", "20")
      expect(initial_session.store.get("selection")).to eq("20")
    end

    it "should set and get values on a different sessions with the same mobile number and session id" do
      initial_session.store.set("selection", "20")
      expect(subsequent_session.store.get("selection")).to eq("20")
    end

    it "should return all stores data hash during the session" do
      initial_session.store.set("selection", "20")
      initial_session.store.set("selection2", "22")

      expect(subsequent_session.store.all).to eq({ "selection" => "20", "selection2" => "22" })
    end
  end
end
# rubocop:enable Metrics/BlockLength
