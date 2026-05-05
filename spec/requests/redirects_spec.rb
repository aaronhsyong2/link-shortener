require "rails_helper"

RSpec.describe "Redirects", type: :request do
  describe "GET /:slug" do
    it "redirects to the target URL" do
      stub_request(:get, "https://ipinfo.io/127.0.0.1/json").to_timeout
      url = create(:url, target_url: "https://example.com")

      get "/#{url.slug}"
      expect(response).to redirect_to("https://example.com")
    end

    it "tracks a visit" do
      stub_request(:get, "https://ipinfo.io/127.0.0.1/json").to_timeout
      url = create(:url)

      expect { get "/#{url.slug}" }.to change(Visit, :count).by(1)
    end

    it "increments clicks_count" do
      stub_request(:get, "https://ipinfo.io/127.0.0.1/json").to_timeout
      url = create(:url)

      get "/#{url.slug}"
      expect(url.reload.clicks_count).to eq(1)
    end

    it "returns 404 for unknown slugs" do
      get "/nonexistent"
      expect(response).to have_http_status(:not_found)
    end

    it "returns 404 for invalid slug characters" do
      get "/!!!"
      expect(response).to have_http_status(:not_found)
    end

    it "populates enriched visit fields from request headers" do
      stub_request(:get, "https://ipinfo.io/127.0.0.1/json").to_timeout
      url = create(:url)

      get "/#{url.slug}", headers: {
        "User-Agent" => "Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1",
        "Referer" => "https://twitter.com/status/123"
      }

      visit = Visit.last
      expect(visit).not_to be_nil
      expect(visit.user_agent).to include("iPhone")
      expect(visit.browser).to eq("Safari")
      expect(visit.os).to include("iOS")
      expect(visit.device_type).to eq("mobile")
      expect(visit.is_bot).to be false
      expect(visit.referer).to eq("https://twitter.com/status/123")
      expect(visit.referer_domain).to eq("twitter.com")
    end

    it "handles missing referer gracefully" do
      stub_request(:get, "https://ipinfo.io/127.0.0.1/json").to_timeout
      url = create(:url)

      get "/#{url.slug}"

      visit = Visit.last
      expect(visit.referer).to be_nil
      expect(visit.referer_domain).to be_nil
    end
  end
end
