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
  end

  it "delegates model methods transparently" do
    expect(decorated.url).to eq(visit.url)
    expect(decorated.ip_address).to eq("8.8.8.8")
  end
end
