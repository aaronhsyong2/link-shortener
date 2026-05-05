require "rails_helper"

RSpec.describe RedirectsController, type: :controller do
  describe "#parse_user_agent" do
    subject { controller.send(:parse_user_agent, ua_string) }

    context "with a bot user-agent" do
      let(:ua_string) { "Googlebot/2.1 (+http://www.google.com/bot.html)" }

      it "detects bot and uses bot name" do
        expect(subject[:is_bot]).to be true
        expect(subject[:browser]).to eq("Google Bot")
      end
    end

    context "with a blank user-agent" do
      let(:ua_string) { "" }

      it "returns nil fields" do
        expect(subject[:browser]).to be_nil
        expect(subject[:os]).to be_nil
        expect(subject[:device_type]).to be_nil
        expect(subject[:is_bot]).to be false
      end
    end

    context "with nil user-agent" do
      let(:ua_string) { nil }

      it "returns nil fields" do
        expect(subject[:browser]).to be_nil
        expect(subject[:is_bot]).to be false
      end
    end

    context "with a desktop Chrome user-agent" do
      let(:ua_string) { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }

      it "detects browser and device type" do
        expect(subject[:browser]).to eq("Chrome")
        expect(subject[:os]).to include("macOS")
        expect(subject[:device_type]).to eq("desktop")
        expect(subject[:is_bot]).to be false
      end
    end
  end

  describe "#extract_referer_domain" do
    subject { controller.send(:extract_referer_domain, referer) }

    context "with valid URL" do
      let(:referer) { "https://twitter.com/status/123" }
      it { is_expected.to eq("twitter.com") }
    end

    context "with nil" do
      let(:referer) { nil }
      it { is_expected.to be_nil }
    end

    context "with blank string" do
      let(:referer) { "" }
      it { is_expected.to be_nil }
    end

    context "with malformed URL" do
      let(:referer) { "not a url %%%" }
      it { is_expected.to be_nil }
    end
  end
end
