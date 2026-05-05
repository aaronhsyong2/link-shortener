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

  describe "#daily_series" do
    it "returns [date, count] pairs for last 30 days by default" do
      create(:visit, url: url, visited_at: Time.current.middle_of_day)
      create(:visit, url: url, visited_at: Time.current.middle_of_day + 2.hours)
      create(:visit, url: url, visited_at: 3.days.ago.middle_of_day)

      result = query.daily_series
      expect(result.length).to eq(30)
      expect(result.last).to eq([ Date.current, 2 ])
      expect(result.find { |d, _| d == 3.days.ago.to_date }).to eq([ 3.days.ago.to_date, 1 ])
    end

    it "accepts custom days parameter" do
      result = query.daily_series(days: 7)
      expect(result.length).to eq(7)
    end

    it "fills zero for days with no clicks" do
      result = query.daily_series(days: 7)
      expect(result.all? { |_, count| count == 0 }).to be true
    end

    it "excludes bot visits by default" do
      create(:visit, url: url, visited_at: Time.current.middle_of_day, is_bot: true)
      create(:visit, url: url, visited_at: Time.current.middle_of_day, is_bot: false)

      result = query.daily_series(days: 1)
      expect(result.last.last).to eq(1)
    end

    it "includes bot visits when requested" do
      create(:visit, url: url, visited_at: Time.current.middle_of_day, is_bot: true)
      create(:visit, url: url, visited_at: Time.current.middle_of_day, is_bot: false)

      result = query.daily_series(days: 1, include_bots: true)
      expect(result.last.last).to eq(2)
    end
  end

  describe "#hourly_distribution" do
    it "returns counts grouped by hour 0-23" do
      create(:visit, url: url, visited_at: Time.utc(2026, 1, 1, 9, 0))
      create(:visit, url: url, visited_at: Time.utc(2026, 1, 1, 9, 30))
      create(:visit, url: url, visited_at: Time.utc(2026, 1, 1, 14, 0))

      result = query.hourly_distribution
      expect(result[9]).to eq(2)
      expect(result[14]).to eq(1)
      expect(result[0]).to eq(0)
    end

    it "excludes bot visits by default" do
      create(:visit, url: url, visited_at: Time.utc(2026, 1, 1, 9, 0), is_bot: true)

      result = query.hourly_distribution
      expect(result[9]).to eq(0)
    end

    it "includes bots when requested" do
      create(:visit, url: url, visited_at: Time.utc(2026, 1, 1, 9, 0), is_bot: true)

      result = query.hourly_distribution(include_bots: true)
      expect(result[9]).to eq(1)
    end
  end

  describe "#first_click" do
    it "returns timestamp of earliest visit" do
      early = create(:visit, url: url, visited_at: 5.days.ago)
      create(:visit, url: url, visited_at: 1.day.ago)

      expect(query.first_click).to be_within(1.second).of(early.visited_at)
    end

    it "returns nil when no visits" do
      expect(query.first_click).to be_nil
    end

    it "excludes bot visits by default" do
      bot = create(:visit, url: url, visited_at: 5.days.ago, is_bot: true)
      human = create(:visit, url: url, visited_at: 1.day.ago, is_bot: false)

      expect(query.first_click).to be_within(1.second).of(human.visited_at)
    end
  end

  describe "#last_click" do
    it "returns timestamp of latest visit" do
      create(:visit, url: url, visited_at: 5.days.ago)
      latest = create(:visit, url: url, visited_at: 1.hour.ago)

      expect(query.last_click).to be_within(1.second).of(latest.visited_at)
    end

    it "returns nil when no visits" do
      expect(query.last_click).to be_nil
    end

    it "excludes bot visits by default" do
      bot = create(:visit, url: url, visited_at: 1.minute.ago, is_bot: true)
      human = create(:visit, url: url, visited_at: 1.day.ago, is_bot: false)

      expect(query.last_click).to be_within(1.second).of(human.visited_at)
    end
  end

  describe "#visits_by_browser" do
    it "returns grouped counts sorted by frequency descending" do
      create_list(:visit, 3, url: url, browser: "Chrome")
      create_list(:visit, 1, url: url, browser: "Firefox")
      create_list(:visit, 2, url: url, browser: "Safari")

      result = query.visits_by_browser
      expect(result).to eq([ [ "Chrome", 3 ], [ "Safari", 2 ], [ "Firefox", 1 ] ])
    end

    it "returns empty array when no visits" do
      expect(query.visits_by_browser).to be_empty
    end

    it "excludes bots by default" do
      create(:visit, url: url, browser: "Chrome", is_bot: false)
      create(:visit, url: url, browser: "Googlebot", is_bot: true)

      result = query.visits_by_browser
      expect(result).to eq([ [ "Chrome", 1 ] ])
    end

    it "includes bots when requested" do
      create(:visit, url: url, browser: "Chrome", is_bot: false)
      create(:visit, url: url, browser: "Googlebot", is_bot: true)

      result = query.visits_by_browser(include_bots: true)
      expect(result.length).to eq(2)
    end
  end

  describe "#visits_by_os" do
    it "returns grouped counts sorted by frequency descending" do
      create_list(:visit, 3, url: url, os: "macOS")
      create_list(:visit, 1, url: url, os: "Windows")

      result = query.visits_by_os
      expect(result).to eq([ [ "macOS", 3 ], [ "Windows", 1 ] ])
    end

    it "excludes bots by default" do
      create(:visit, url: url, os: "macOS", is_bot: false)
      create(:visit, url: url, os: "Linux", is_bot: true)

      expect(query.visits_by_os).to eq([ [ "macOS", 1 ] ])
    end
  end

  describe "#visits_by_device_type" do
    it "returns grouped counts sorted by frequency descending" do
      create_list(:visit, 3, url: url, device_type: "desktop")
      create_list(:visit, 2, url: url, device_type: "mobile")
      create_list(:visit, 1, url: url, device_type: "tablet")

      result = query.visits_by_device_type
      expect(result).to eq([ [ "desktop", 3 ], [ "mobile", 2 ], [ "tablet", 1 ] ])
    end

    it "excludes bots by default" do
      create(:visit, url: url, device_type: "desktop", is_bot: false)
      create(:visit, url: url, device_type: "desktop", is_bot: true)

      expect(query.visits_by_device_type).to eq([ [ "desktop", 1 ] ])
    end
  end

  describe "#visits_by_referer_domain" do
    it "returns grouped counts sorted by frequency descending" do
      create_list(:visit, 3, url: url, referer_domain: "google.com")
      create_list(:visit, 1, url: url, referer_domain: "twitter.com")
      create_list(:visit, 2, url: url, referer_domain: "reddit.com")

      result = query.visits_by_referer_domain
      expect(result).to eq([ [ "google.com", 3 ], [ "reddit.com", 2 ], [ "twitter.com", 1 ] ])
    end

    it "excludes bots by default" do
      create(:visit, url: url, referer_domain: "google.com", is_bot: false)
      create(:visit, url: url, referer_domain: "bot-net.com", is_bot: true)

      expect(query.visits_by_referer_domain).to eq([ [ "google.com", 1 ] ])
    end

    it "handles nil referer_domain" do
      create(:visit, url: url, referer_domain: nil)
      create(:visit, url: url, referer_domain: "google.com")

      result = query.visits_by_referer_domain
      expect(result).to include([ "google.com", 1 ])
      expect(result).to include([ nil, 1 ])
    end
  end
end
