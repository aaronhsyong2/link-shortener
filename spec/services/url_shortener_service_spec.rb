require "rails_helper"

RSpec.describe UrlShortenerService, type: :model do
  describe ".call" do
    it "creates a persisted url record" do
      url = described_class.call(target_url: "https://example.com", title: "Example")
      expect(url).to be_persisted
      expect(url.target_url).to eq("https://example.com")
      expect(url.title).to eq("Example")
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

    it "produces a deterministic slug from id" do
      url = described_class.call(target_url: "https://example.com")
      expect(url.slug).to be_present
      expect(url.slug.length).to be >= 4
    end
  end
end
