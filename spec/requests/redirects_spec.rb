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
  end
end
