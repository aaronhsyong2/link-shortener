require "rails_helper"

RSpec.describe ResolveGeoJob, type: :job do
  include ActiveJob::TestHelper
  include ActionCable::TestHelper

  describe "#perform" do
    it "resolves geo data and updates the visit" do
      visit = create(:visit, country: nil, city: nil, ip_address: "8.8.8.8")
      stub_request(:get, "https://ipinfo.io/8.8.8.8/json")
        .to_return(
          status: 200,
          body: { country: "US", city: "Mountain View" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      described_class.new.perform(visit.id)

      visit.reload
      expect(visit.country).to eq("US")
      expect(visit.city).to eq("Mountain View")
    end

    it "skips if visit already has country" do
      visit = create(:visit, country: "US", city: "NYC", ip_address: "8.8.8.8")

      described_class.new.perform(visit.id)

      # No HTTP request made — webmock would raise if it was
      expect(visit.reload.country).to eq("US")
    end

    it "skips if visit not found" do
      expect { described_class.new.perform(-1) }.not_to raise_error
    end

    it "sets Unknown on failure" do
      visit = create(:visit, country: nil, city: nil, ip_address: "8.8.8.8")
      stub_request(:get, "https://ipinfo.io/8.8.8.8/json").to_timeout

      described_class.new.perform(visit.id)

      visit.reload
      expect(visit.country).to eq("Unknown")
      expect(visit.city).to eq("Unknown")
    end

    it "broadcasts geo update on success" do
      visit = create(:visit, country: nil, city: nil, ip_address: "8.8.8.8")
      stub_request(:get, "https://ipinfo.io/8.8.8.8/json")
        .to_return(
          status: 200,
          body: { country: "US", city: "Mountain View" }.to_json,
          headers: { "Content-Type" => "application/json" }
        )

      assert_broadcasts(visit.url.to_gid_param, 1) do
        perform_enqueued_jobs do
          described_class.new.perform(visit.id)
        end
      end
    end
  end
end
