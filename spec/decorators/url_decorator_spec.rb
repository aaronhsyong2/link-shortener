require "rails_helper"

RSpec.describe UrlDecorator do
  let(:url) { create(:url, title: "Example", created_at: Time.zone.parse("2026-03-29 14:30:00")) }
  let(:decorated) { described_class.new(url) }

  describe "#display_title" do
    it "returns the title when present" do
      expect(decorated.display_title).to eq("Example")
    end

    it "returns fallback when title is nil" do
      url.update_column(:title, nil)
      expect(decorated.display_title).to eq("No title available")
    end

    it "returns fallback when title is blank" do
      url.update_column(:title, "")
      expect(decorated.display_title).to eq("No title available")
    end
  end

  describe "#formatted_created_at" do
    it "formats the date" do
      expect(decorated.formatted_created_at).to eq("March 29, 2026 at 14:30")
    end
  end

  it "delegates model methods transparently" do
    expect(decorated.target_url).to eq(url.target_url)
    expect(decorated.short_code).to eq(url.short_code)
    expect(decorated.clicks_count).to eq(url.clicks_count)
  end
end
