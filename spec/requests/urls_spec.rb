require "rails_helper"

RSpec.describe "Urls", type: :request do
  describe "GET /urls" do
    it "returns success" do
      get urls_path
      expect(response).to have_http_status(:success)
    end

    it "displays all urls" do
      create(:url, title: "First")
      create(:url, title: "Second")
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

    it "shows empty state when no URLs in session" do
      get new_url_path
      expect(response.body).to include("No URLs shortened yet")
    end

    it "shows recent URLs from session" do
      post urls_path, params: { url: { target_url: "https://example.com" } }
      get new_url_path
      expect(response.body).to include(Url.last.slug)
    end

    it "does not show URLs from other sessions" do
      other_url = create(:url, title: "Other Person URL")
      get new_url_path
      expect(response.body).not_to include(other_url.slug)
      expect(response.body).to include("No URLs shortened yet")
    end

    it "handles deleted URLs gracefully" do
      post urls_path, params: { url: { target_url: "https://example.com" } }
      Url.last.destroy
      get new_url_path
      expect(response.body).to include("No URLs shortened yet")
    end
  end

  describe "POST /urls" do
    it "creates a new url and redirects to show" do
      expect {
        post urls_path, params: { url: { target_url: "https://example.com" } }
      }.to change(Url, :count).by(1)

      expect(response).to redirect_to(url_path(Url.last))
    end

    it "enqueues a title fetch job" do
      expect {
        post urls_path, params: { url: { target_url: "https://example.com" } }
      }.to have_enqueued_job(FetchTitleJob)
    end

    it "creates url without title (fetched async)" do
      post urls_path, params: { url: { target_url: "https://example.com" } }
      expect(Url.last.title).to be_nil
    end

    it "rejects invalid URLs" do
      post urls_path, params: { url: { target_url: "not-a-url" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "rejects blank URLs" do
      post urls_path, params: { url: { target_url: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "stores URL ID in session and shows on homepage" do
      post urls_path, params: { url: { target_url: "https://example.com" } }
      get new_url_path
      expect(response.body).to include(Url.last.slug)
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
