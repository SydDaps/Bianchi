# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.describe Bianchi::USSD::Page do
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

  context "delegators" do
    it "should return session value when a session delegator is called on a page objects" do
      expect(page.session_mobile_number).to eq "+233557711911"
    end
  end

  context "redirects" do
    it "should redirect to menu page with the redirect command" do
      expect { page.redirect_to_main_menu_page_3 }.to raise_error do |error|
        expect(error).to be_a(Bianchi::USSD::PageLoadError)
        expect(error.message).to eq(
          <<~MSG
            \n
            USSD::MainMenu::Page3 is supposed to be defined to process main menu Page3.
            generate menu page with `bianchi g menu main page 3`
          MSG
        )
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
