require "rails_helper"

RSpec.describe UrlsHelper, type: :helper do
  describe "#safe_url" do
    it "returns the URL for http scheme" do
      expect(helper.safe_url("http://example.com")).to eq("http://example.com")
    end

    it "returns the URL for https scheme" do
      expect(helper.safe_url("https://example.com")).to eq("https://example.com")
    end

    it "returns # for javascript: URLs" do
      expect(helper.safe_url("javascript:alert('xss')")).to eq("#")
    end

    it "returns # for data: URLs" do
      expect(helper.safe_url("data:text/html,<h1>xss</h1>")).to eq("#")
    end

    it "returns # for invalid URLs" do
      expect(helper.safe_url("not a url at all")).to eq("#")
    end
  end
end
