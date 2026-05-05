require "rails_helper"

RSpec.describe UrlDecorator do
  let(:url) { create(:url, title: "Example", created_at: Time.zone.parse("2026-03-29 14:30:00")) }
  let(:decorated) { described_class.new(url) }

  describe "#display_title" do
    it "returns the title when present" do
      expect(decorated.display_title).to eq("Example")
    end

    it "returns 'Fetching title...' when title is nil and job not yet completed" do
      url.update_columns(title: nil, title_fetched_at: nil)
      expect(decorated.display_title).to eq("Fetching title...")
    end

    it "returns 'No title available' when title is nil and job completed" do
      url.update_columns(title: nil, title_fetched_at: Time.current)
      expect(decorated.display_title).to eq("No title available")
    end

    it "returns 'No title available' when title is blank and job completed" do
      url.update_columns(title: "", title_fetched_at: Time.current)
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
    expect(decorated.slug).to eq(url.slug)
    expect(decorated.clicks_count).to eq(url.clicks_count)
  end
end
