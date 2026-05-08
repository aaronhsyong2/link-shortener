require "rails_helper"

RSpec.describe FetchTitleJob, type: :job do
  include ActiveJob::TestHelper
  include ActionCable::TestHelper

  describe "#perform" do
    it "fetches and updates the title" do
      url = create(:url, title: nil)
      stub_request(:get, url.target_url)
        .to_return(
          status: 200,
          body: "<html><head><title>Fetched Title</title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )

      described_class.new.perform(url.id, url.target_url)
      expect(url.reload.title).to eq("Fetched Title")
    end

    it "skips if url already has a title" do
      url = create(:url, title: "Existing")
      stub_request(:get, url.target_url)
        .to_return(status: 200, body: "<html><head><title>New Title</title></head></html>", headers: { "Content-Type" => "text/html" })

      described_class.new.perform(url.id, url.target_url)
      expect(url.reload.title).to eq("Existing")
    end

    it "skips if url no longer exists" do
      stub_request(:get, "https://gone.example.com").to_return(status: 200, body: "<html><head><title>Gone</title></head></html>", headers: { "Content-Type" => "text/html" })
      expect { described_class.new.perform(999999, "https://gone.example.com") }.not_to raise_error
    end

    it "sets title_fetched_at even when fetch returns nil" do
      url = create(:url, title: nil)
      stub_request(:get, url.target_url).to_timeout

      described_class.new.perform(url.id, url.target_url)
      url.reload
      expect(url.title).to be_nil
      expect(url.title_fetched_at).to be_present
    end

    it "marks title_fetched_at even when service raises" do
      url = create(:url, title: nil)
      allow(UrlMetadataService).to receive(:call).and_raise(StandardError, "connection reset")

      expect { described_class.new.perform(url.id, url.target_url) }.not_to raise_error
      expect(url.reload.title_fetched_at).to be_present
      expect(url.title).to be_nil
    end

    it "calls HTTP service before DB lookup" do
      url = create(:url, title: nil)
      call_order = []

      allow(UrlMetadataService).to receive(:call) do |_target_url|
        call_order << :http
        "Title"
      end
      allow(Url).to receive(:find_by) do |**_args|
        call_order << :db
        url
      end

      described_class.new.perform(url.id, url.target_url)
      expect(call_order).to eq([ :http, :db ])
    end

    it "broadcasts title update via Turbo Stream" do
      url = create(:url, title: nil)
      stub_request(:get, url.target_url)
        .to_return(
          status: 200,
          body: "<html><head><title>Broadcast Title</title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )

      assert_broadcasts("url_titles", 1) do
        described_class.new.perform(url.id, url.target_url)
      end
    end
  end
end
