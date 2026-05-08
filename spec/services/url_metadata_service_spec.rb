require "rails_helper"

RSpec.describe UrlMetadataService, type: :model do
  describe ".call" do
    it "returns the page title for a valid URL" do
      stub_request(:get, "https://example.com")
        .to_return(
          status: 200,
          body: "<html><head><title>Example Domain</title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )

      title = described_class.call("https://example.com")
      expect(title).to eq("Example Domain")
    end

    it "returns nil for non-HTML responses" do
      stub_request(:get, "https://example.com/file.pdf")
        .to_return(
          status: 200,
          body: "binary content",
          headers: { "Content-Type" => "application/pdf" }
        )

      title = described_class.call("https://example.com/file.pdf")
      expect(title).to be_nil
    end

    it "returns nil for invalid URLs" do
      title = described_class.call("not-a-url")
      expect(title).to be_nil
    end

    it "returns nil on timeout" do
      stub_request(:get, "https://slow.example.com").to_timeout

      title = described_class.call("https://slow.example.com")
      expect(title).to be_nil
    end

    it "returns nil on connection error" do
      stub_request(:get, "https://down.example.com").to_raise(SocketError)

      title = described_class.call("https://down.example.com")
      expect(title).to be_nil
    end

    it "follows redirects" do
      stub_request(:get, "https://example.com")
        .to_return(status: 301, headers: { "Location" => "https://www.example.com" })
      stub_request(:get, "https://www.example.com")
        .to_return(
          status: 200,
          body: "<html><head><title>Redirected</title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )

      title = described_class.call("https://example.com")
      expect(title).to eq("Redirected")
    end

    it "truncates long titles to 255 characters" do
      long_title = "A" * 300
      stub_request(:get, "https://example.com")
        .to_return(
          status: 200,
          body: "<html><head><title>#{long_title}</title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )

      title = described_class.call("https://example.com")
      expect(title.length).to eq(255)
    end

    it "returns nil when HTML has no title tag" do
      stub_request(:get, "https://example.com")
        .to_return(
          status: 200,
          body: "<html><head></head><body>No title here</body></html>",
          headers: { "Content-Type" => "text/html" }
        )

      title = described_class.call("https://example.com")
      expect(title).to be_nil
    end

    it "returns empty string for whitespace-only title tag" do
      stub_request(:get, "https://example.com")
        .to_return(
          status: 200,
          body: "<html><head><title>   </title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )

      title = described_class.call("https://example.com")
      expect(title).to eq("")
    end

    it "returns nil when redirect limit is exhausted" do
      stub_request(:get, "https://example.com")
        .to_return(status: 301, headers: { "Location" => "https://example.com/a" })
      stub_request(:get, "https://example.com/a")
        .to_return(status: 301, headers: { "Location" => "https://example.com/b" })
      stub_request(:get, "https://example.com/b")
        .to_return(status: 301, headers: { "Location" => "https://example.com/c" })
      stub_request(:get, "https://example.com/c")
        .to_return(status: 301, headers: { "Location" => "https://example.com/d" })

      title = described_class.call("https://example.com")
      expect(title).to be_nil
    end

    it "handles relative redirect Location headers" do
      stub_request(:get, "https://example.com")
        .to_return(status: 301, headers: { "Location" => "/new-page" })
      stub_request(:get, "https://example.com/new-page")
        .to_return(
          status: 200,
          body: "<html><head><title>Relative Redirect</title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )

      title = described_class.call("https://example.com")
      expect(title).to eq("Relative Redirect")
    end
  end
end
