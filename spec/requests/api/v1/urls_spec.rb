require "rails_helper"

RSpec.describe "Api::V1::Urls", type: :request do
  describe "POST /api/v1/urls" do
    before do
      stub_request(:get, "https://example.com")
        .to_return(
          status: 200,
          body: "<html><head><title>Example</title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )
    end

    it "creates a short URL and returns JSON" do
      post "/api/v1/urls",
        params: { url: { target_url: "https://example.com" } },
        as: :json

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["short_code"]).to be_present
      expect(json["target_url"]).to eq("https://example.com")
      expect(json["title"]).to eq("Example")
      expect(json["short_url"]).to include(json["short_code"])
      expect(json["clicks_count"]).to eq(0)
      expect(json["created_at"]).to be_present
    end

    it "returns errors for invalid URLs" do
      post "/api/v1/urls",
        params: { url: { target_url: "not-a-url" } },
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["error"]).to be_present
    end

    it "returns errors for blank URLs" do
      post "/api/v1/urls",
        params: { url: { target_url: "" } },
        as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /api/v1/urls/:short_code" do
    it "returns URL details" do
      url = create(:url, short_code: "api123", title: "Test")

      get "/api/v1/urls/api123", as: :json

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["short_code"]).to eq("api123")
      expect(json["target_url"]).to eq(url.target_url)
      expect(json["title"]).to eq("Test")
    end

    it "returns 404 for unknown short codes" do
      get "/api/v1/urls/nonexistent", as: :json

      expect(response).to have_http_status(:not_found)
      json = JSON.parse(response.body)
      expect(json["error"]).to eq("Not found")
    end
  end
end
