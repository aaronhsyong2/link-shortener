require "rails_helper"

RSpec.describe UrlAnalyticsQuery do
  let(:url) { create(:url) }
  let(:query) { described_class.new(url) }

  describe "#total_clicks" do
    it "returns the click count" do
      url.update!(clicks_count: 42)
      expect(query.total_clicks).to eq(42)
    end
  end

  describe "#visits_by_country" do
    it "groups visits by country, sorted by count descending" do
      create(:visit, url: url, country: "US")
      create(:visit, url: url, country: "US")
      create(:visit, url: url, country: "MY")

      result = query.visits_by_country
      expect(result.first).to eq([ "US", 2 ])
      expect(result.last).to eq([ "MY", 1 ])
    end

    it "returns empty array when no visits" do
      expect(query.visits_by_country).to be_empty
    end
  end

  describe "#visits_by_city" do
    it "groups visits by city, sorted by count descending" do
      create(:visit, url: url, city: "NYC")
      create(:visit, url: url, city: "NYC")
      create(:visit, url: url, city: "KL")

      result = query.visits_by_city
      expect(result.first).to eq([ "NYC", 2 ])
      expect(result.last).to eq([ "KL", 1 ])
    end
  end

  describe "#recent_visits" do
    it "returns visits ordered by most recent first" do
      old = create(:visit, url: url, visited_at: 2.days.ago)
      recent = create(:visit, url: url, visited_at: 1.hour.ago)

      expect(query.recent_visits.first).to eq(recent)
      expect(query.recent_visits.last).to eq(old)
    end

    it "limits results" do
      3.times { create(:visit, url: url) }
      expect(query.recent_visits(limit: 2).size).to eq(2)
    end
  end
end
