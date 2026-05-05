require "rails_helper"

RSpec.describe VisitDecorator do
  let(:visit) { create(:visit, visited_at: Time.zone.parse("2026-03-30 14:30:00"), ip_address: "8.8.8.8", country: "US", city: "Mountain View") }
  let(:decorated) { described_class.new(visit) }

  describe "#formatted_timestamp" do
    it "formats with UTC label" do
      expect(decorated.formatted_timestamp).to eq("2026-03-30 14:30:00 UTC")
    end
  end

  describe "#iso_timestamp" do
    it "returns ISO 8601 format" do
      expect(decorated.iso_timestamp).to eq("2026-03-30T14:30:00Z")
    end
  end

  describe "#masked_ip" do
    it "masks the last two octets" do
      expect(decorated.masked_ip).to eq("8.8.***. ***")
    end

    it "returns the original for non-IPv4" do
      visit.update_column(:ip_address, "::1")
      expect(decorated.masked_ip).to eq("::1")
    end
  end

  describe "#display_location" do
    it "combines city and country" do
      expect(decorated.display_location).to eq("Mountain View, US")
    end

    it "shows only country when city is Unknown" do
      visit.update_column(:city, "Unknown")
      expect(decorated.display_location).to eq("US")
    end

    it "returns Unknown when both are Unknown" do
      visit.update_column(:city, "Unknown")
      visit.update_column(:country, "Unknown")
      expect(decorated.display_location).to eq("Unknown")
    end

    it "returns Resolving... when country is nil" do
      visit.update_column(:country, nil)
      expect(decorated.display_location).to eq("Resolving...")
    end
  end

  describe "#display_browser" do
    it "returns browser name" do
      expect(decorated.display_browser).to eq("Chrome")
    end

    it "returns Unknown when nil" do
      visit.update_column(:browser, nil)
      expect(decorated.display_browser).to eq("Unknown")
    end
  end

  describe "#display_os" do
    it "returns OS name" do
      expect(decorated.display_os).to eq("macOS")
    end

    it "returns Unknown when nil" do
      visit.update_column(:os, nil)
      expect(decorated.display_os).to eq("Unknown")
    end
  end

  describe "#display_device_type" do
    it "returns capitalized device type" do
      expect(decorated.display_device_type).to eq("Desktop")
    end

    it "returns Unknown when nil" do
      visit.update_column(:device_type, nil)
      expect(decorated.display_device_type).to eq("Unknown")
    end
  end

  describe "#masked_referer" do
    it "returns referer domain" do
      expect(decorated.masked_referer).to eq("google.com")
    end

    it "returns Direct when nil" do
      visit.update_column(:referer_domain, nil)
      expect(decorated.masked_referer).to eq("Direct")
    end
  end

  describe "#bot_indicator" do
    it "returns Human for non-bots" do
      expect(decorated.bot_indicator).to eq("Human")
    end

    it "returns Bot for bots" do
      visit.update_column(:is_bot, true)
      expect(decorated.bot_indicator).to eq("Bot")
    end
  end

  it "delegates model methods transparently" do
    expect(decorated.url).to eq(visit.url)
    expect(decorated.ip_address).to eq("8.8.8.8")
  end
end
