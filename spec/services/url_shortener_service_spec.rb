require "rails_helper"

RSpec.describe UrlShortenerService, type: :model do
  describe ".call" do
    it "creates a url with a generated short code" do
      url = described_class.call(target_url: "https://example.com", title: "Example")
      expect(url).to be_persisted
      expect(url.short_code).to be_present
      expect(url.short_code.length).to eq(6)
      expect(url.target_url).to eq("https://example.com")
      expect(url.title).to eq("Example")
    end

    it "generates short codes using Base62 characters only" do
      url = described_class.call(target_url: "https://example.com")
      expect(url.short_code).to match(/\A[a-zA-Z0-9]+\z/)
    end

    it "generates unique short codes" do
      codes = 10.times.map { described_class.call(target_url: "https://example.com").short_code }
      expect(codes.uniq.length).to eq(10)
    end

    it "sets clicks_count to 0" do
      url = described_class.call(target_url: "https://example.com")
      expect(url.clicks_count).to eq(0)
    end

    it "allows nil title" do
      url = described_class.call(target_url: "https://example.com", title: nil)
      expect(url).to be_persisted
      expect(url.title).to be_nil
    end
  end
end
