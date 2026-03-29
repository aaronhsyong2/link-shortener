require "rails_helper"

RSpec.describe "Urls", type: :request do
  describe "GET /urls" do
    it "returns success" do
      get urls_path
      expect(response).to have_http_status(:success)
    end

    it "displays all urls" do
      create(:url, short_code: "aaa111", title: "First")
      create(:url, short_code: "bbb222", title: "Second")
      get urls_path
      expect(response.body).to include("First")
      expect(response.body).to include("Second")
    end
  end

  describe "GET /urls/new" do
    it "returns success" do
      get new_url_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /urls" do
    before do
      stub_request(:get, "https://example.com")
        .to_return(
          status: 200,
          body: "<html><head><title>Example Domain</title></head></html>",
          headers: { "Content-Type" => "text/html" }
        )
    end

    it "creates a new url and redirects to show" do
      expect {
        post urls_path, params: { url: { target_url: "https://example.com" } }
      }.to change(Url, :count).by(1)

      expect(response).to redirect_to(url_path(Url.last))
    end

    it "fetches the page title" do
      post urls_path, params: { url: { target_url: "https://example.com" } }
      expect(Url.last.title).to eq("Example Domain")
    end

    it "rejects invalid URLs" do
      post urls_path, params: { url: { target_url: "not-a-url" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "rejects blank URLs" do
      post urls_path, params: { url: { target_url: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "GET /urls/:id" do
    it "returns success" do
      url = create(:url)
      get url_path(url)
      expect(response).to have_http_status(:success)
    end
  end
end
