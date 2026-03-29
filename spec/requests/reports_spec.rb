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
  end
end
