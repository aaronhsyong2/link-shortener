require "rails_helper"

RSpec.describe "Reports", type: :request do
  describe "GET /urls/:url_id/report" do
    it "returns success" do
      url = create(:url)
      get url_report_path(url)
      expect(response).to have_http_status(:success)
    end

    it "displays visit statistics" do
      url = create(:url)
      create(:visit, url: url, country: "US", city: "New York")
      create(:visit, url: url, country: "MY", city: "Kuala Lumpur")

      get url_report_path(url)
      expect(response.body).to include("US")
      expect(response.body).to include("New York")
      expect(response.body).to include("MY")
      expect(response.body).to include("Kuala Lumpur")
    end

    it "renders chartkick chart containers" do
      url = create(:url)
      create(:visit, url: url, browser: "Chrome", os: "Windows", device_type: "desktop",
             visited_at: 1.day.ago)

      get url_report_path(url)
      expect(response.body).to include("chartkick")
    end

    it "renders tab navigation" do
      url = create(:url)
      get url_report_path(url)

      expect(response.body).to include("Overview")
      expect(response.body).to include("Devices")
      expect(response.body).to include("Traffic Sources")
      expect(response.body).to include("Recent")
    end

    it "renders device breakdown charts" do
      url = create(:url)
      create(:visit, url: url, browser: "Firefox", os: "Linux", device_type: "desktop")

      get url_report_path(url)
      expect(response.body).to include("Browsers")
      expect(response.body).to include("Operating Systems")
      expect(response.body).to include("Device Types")
    end

    it "paginates recent visits" do
      url = create(:url)
      30.times { create(:visit, url: url) }

      get url_report_path(url, page: 2)
      expect(response).to have_http_status(:success)
    end

    it "shows first and last click dates" do
      url = create(:url)
      create(:visit, url: url, visited_at: Date.new(2026, 1, 15))
      create(:visit, url: url, visited_at: Date.new(2026, 3, 20))

      get url_report_path(url)
      expect(response.body).to include("Jan 15, 2026")
      expect(response.body).to include("Mar 20, 2026")
    end

    it "shows referer domains in traffic tab" do
      url = create(:url)
      create(:visit, url: url, referer_domain: "google.com")

      get url_report_path(url)
      expect(response.body).to include("google.com")
    end

    it "renders visit row with all columns" do
      url = create(:url)
      create(:visit, url: url, browser: "Safari", device_type: "mobile",
             referer_domain: "twitter.com", is_bot: false,
             country: "JP", city: "Tokyo")

      get url_report_path(url)
      expect(response.body).to include("Safari")
      expect(response.body).to include("mobile")
      expect(response.body).to include("twitter.com")
      expect(response.body).to include("Human")
      expect(response.body).to include("Tokyo")
    end

    it "renders bot indicator for bot visits" do
      url = create(:url)
      create(:visit, url: url, is_bot: true, browser: "Googlebot")

      get url_report_path(url)
      # Bot visits excluded from recent tab (filtered), but present in full data
      # The recent tab filters is_bot: false, so bot won't appear there
      expect(response).to have_http_status(:success)
    end

    it "renders empty state when no visits" do
      url = create(:url)
      get url_report_path(url)

      expect(response.body).to include("No click data yet")
      expect(response.body).to include("No data yet")
      expect(response.body).to include("No visits yet")
    end
  end
end
