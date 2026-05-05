require "rails_helper"

RSpec.describe GeolocationService, type: :model do
  describe ".call" do
    it "returns country and city for a public IP" do
      stub_request(:get, "https://ipinfo.io/8.8.8.8/json")
        .to_return(
          status: 200,
          body: { country: "US", city: "Mountain View" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      result = described_class.call("8.8.8.8")
      expect(result[:country]).to eq("US")
      expect(result[:city]).to eq("Mountain View")
    end

    it "returns Unknown for private IPs" do
      result = described_class.call("127.0.0.1")
      expect(result[:country]).to eq("Unknown")
      expect(result[:city]).to eq("Unknown")
    end

    it "returns Unknown for localhost IPv6" do
      result = described_class.call("::1")
      expect(result[:country]).to eq("Unknown")
      expect(result[:city]).to eq("Unknown")
    end

    it "returns Unknown for blank IP" do
      result = described_class.call("")
      expect(result[:country]).to eq("Unknown")
      expect(result[:city]).to eq("Unknown")
    end

    it "returns Unknown on API error" do
      stub_request(:get, "https://ipinfo.io/8.8.8.8/json")
        .to_return(status: 500)

      result = described_class.call("8.8.8.8")
      expect(result[:country]).to eq("Unknown")
      expect(result[:city]).to eq("Unknown")
    end

    it "returns Unknown on timeout" do
      stub_request(:get, "https://ipinfo.io/8.8.8.8/json").to_timeout

      result = described_class.call("8.8.8.8")
      expect(result[:country]).to eq("Unknown")
      expect(result[:city]).to eq("Unknown")
    end
  end

  describe "subnet caching" do
    before do
      allow(Rails).to receive(:cache).and_return(ActiveSupport::Cache::MemoryStore.new)
    end

    it "caches result by /24 subnet" do
      stub = stub_request(:get, "https://ipinfo.io/203.0.113.45/json")
        .to_return(
          status: 200,
          body: { country: "AU", city: "Sydney" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      described_class.call("203.0.113.45")
      result = described_class.call("203.0.113.99")

      expect(result[:country]).to eq("AU")
      expect(result[:city]).to eq("Sydney")
      expect(stub).to have_been_requested.once
    end

    it "makes separate API calls for different subnets" do
      stub1 = stub_request(:get, "https://ipinfo.io/203.0.113.45/json")
        .to_return(
          status: 200,
          body: { country: "AU", city: "Sydney" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )
      stub2 = stub_request(:get, "https://ipinfo.io/198.51.100.10/json")
        .to_return(
          status: 200,
          body: { country: "US", city: "Dallas" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      described_class.call("203.0.113.45")
      described_class.call("198.51.100.10")

      expect(stub1).to have_been_requested.once
      expect(stub2).to have_been_requested.once
    end

    it "does not cache private IP results" do
      expect(Rails.cache).not_to receive(:fetch)
      described_class.call("192.168.1.1")
    end
  end
end
