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
end
