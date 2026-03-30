require "rails_helper"

RSpec.describe FetchTitleJob, type: :job do
  describe "#perform" do
    it "fetches and updates the title" do
      url = create(:url, title: nil)
      stub_request(:get, url.target_url)
        .to_return(
          status: 200,
          body: "<html><head><title>Fetched Title</title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )

      described_class.new.perform(url.id)
      expect(url.reload.title).to eq("Fetched Title")
    end

    it "skips if url already has a title" do
      url = create(:url, title: "Existing")
      described_class.new.perform(url.id)
      expect(url.reload.title).to eq("Existing")
    end

    it "skips if url no longer exists" do
      expect { described_class.new.perform(999999) }.not_to raise_error
    end

    it "does not update if fetch returns nil" do
      url = create(:url, title: nil)
      stub_request(:get, url.target_url).to_timeout

      described_class.new.perform(url.id)
      expect(url.reload.title).to be_nil
    end
  end
end
