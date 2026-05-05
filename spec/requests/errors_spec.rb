require "rails_helper"

RSpec.describe "Error pages", type: :request do
  describe "404 Not Found" do
    it "renders the ERB template with application layout" do
      get "/404"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page not found")
      expect(response.body).to include("LinkShortener")
    end

    it "renders 404 for unknown routes" do
      get "/zz-no-such-page-99"

      expect(response).to have_http_status(:not_found)
      expect(response.body).to include("Page not found")
    end
  end
end
