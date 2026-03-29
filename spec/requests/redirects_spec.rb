require "rails_helper"

RSpec.describe "Redirects", type: :request do
  describe "GET /:short_code" do
    it "redirects to the target URL" do
      stub_request(:get, "https://ipinfo.io/127.0.0.1/json").to_timeout
      url = create(:url, target_url: "https://example.com", short_code: "test12")

      get "/test12"
      expect(response).to redirect_to("https://example.com")
    end

    it "tracks a visit" do
      stub_request(:get, "https://ipinfo.io/127.0.0.1/json").to_timeout
      url = create(:url, short_code: "track1")

      expect { get "/track1" }.to change(Visit, :count).by(1)
    end

    it "increments clicks_count" do
      stub_request(:get, "https://ipinfo.io/127.0.0.1/json").to_timeout
      url = create(:url, short_code: "click1")

      get "/click1"
      expect(url.reload.clicks_count).to eq(1)
    end

    it "returns 404 for unknown short codes" do
      get "/nonexistent"
      expect(response).to have_http_status(:not_found)
    end
  end
end
