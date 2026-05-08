require "rails_helper"

RSpec.describe "Report charts", type: :system do
  describe "Overview tab" do
    it "renders line chart for daily clicks with data" do
      url = create(:url)
      create(:visit, url: url, visited_at: 1.day.ago)
      create(:visit, url: url, visited_at: 2.days.ago)

      visit url_report_path(url)

      expect(page).to have_css("h3", text: "Clicks (Last 30 Days)")
      # Chartkick renders a canvas inside a div
      within(first("[data-tabs-target='panel'][data-tab='overview']")) do
        expect(page).to have_css("canvas", minimum: 2)
      end
    end

    it "renders bar chart for hourly distribution" do
      url = create(:url)
      create(:visit, url: url, visited_at: Time.current.change(hour: 14))

      visit url_report_path(url)

      expect(page).to have_css("h3", text: "Hourly Distribution")
    end

    it "shows empty state when no clicks" do
      url = create(:url)
      visit url_report_path(url)

      # Chartkick renders empty text inside overview panel
      overview = find("[data-tabs-target='panel'][data-tab='overview']")
      expect(overview.text(:all)).to include("No click data yet")
    end
  end

  describe "Devices tab" do
    before do
      @url = create(:url)
      create(:visit, url: @url, browser: "Chrome", os: "Windows", device_type: "desktop")
      create(:visit, url: @url, browser: "Safari", os: "iOS", device_type: "mobile")
      create(:visit, url: @url, browser: "Chrome", os: "Android", device_type: "mobile")
    end

    it "renders pie charts for browsers and OS" do
      visit url_report_path(@url)
      find("a[data-tab='devices']").click

      expect(page).to have_css("h3", text: "Browsers")
      expect(page).to have_css("h3", text: "Operating Systems")
      expect(page).to have_css("h3", text: "Device Types")

      within("[data-tabs-target='panel'][data-tab='devices']") do
        expect(page).to have_css("canvas", minimum: 3)
      end
    end

    it "shows empty state for devices when no visits" do
      empty_url = create(:url)
      visit url_report_path(empty_url)
      find("a[data-tab='devices']").click

      expect(page).to have_content("No data yet")
    end
  end

  describe "Traffic Sources tab" do
    it "renders referer domain table with data" do
      url = create(:url)
      create(:visit, url: url, referer_domain: "google.com")
      create(:visit, url: url, referer_domain: "google.com")
      create(:visit, url: url, referer_domain: "twitter.com")

      visit url_report_path(url)
      find("a[data-tab='traffic']").click

      expect(page).to have_css("h3", text: "Referer Domains")
      expect(page).to have_content("google.com")
      expect(page).to have_content("twitter.com")
    end

    it "renders country and city tables" do
      url = create(:url)
      create(:visit, url: url, country: "US", city: "New York")
      create(:visit, url: url, country: "JP", city: "Tokyo")

      visit url_report_path(url)
      find("a[data-tab='traffic']").click

      expect(page).to have_css("h3", text: "Countries")
      expect(page).to have_content("US")
      expect(page).to have_content("JP")

      expect(page).to have_css("h3", text: "Cities")
      expect(page).to have_content("New York")
      expect(page).to have_content("Tokyo")
    end

    it "shows empty state when no visits" do
      url = create(:url)
      visit url_report_path(url)
      find("a[data-tab='traffic']").click

      expect(page).to have_content("No visits yet")
    end
  end

  describe "Recent tab" do
    it "renders visit table with details" do
      url = create(:url)
      create(:visit, url: url, browser: "Firefox", os: "Linux",
             device_type: "desktop", referer_domain: "reddit.com",
             country: "DE", city: "Berlin", is_bot: false)

      visit url_report_path(url)
      find("a[data-tab='recent']").click

      expect(page).to have_content("Firefox")
      expect(page).to have_content("Berlin")
      expect(page).to have_content("reddit.com")
      expect(page).to have_content("Human")
    end

    it "shows empty table when no visits" do
      url = create(:url)
      visit url_report_path(url)
      find("a[data-tab='recent']").click

      # Table renders with headers but empty body
      expect(page).to have_css("th", text: /timestamp/i)
      expect(page).to have_css("tbody#visits")
      expect(page).not_to have_css("tbody#visits tr")
    end
  end

  describe "summary cards" do
    it "shows correct stats in header cards" do
      url = create(:url)
      create(:visit, url: url, country: "US", visited_at: Date.new(2026, 1, 10))
      create(:visit, url: url, country: "JP", visited_at: Date.new(2026, 5, 1))
      create(:visit, url: url, country: "US", visited_at: Date.new(2026, 3, 15))

      visit url_report_path(url)

      # Total clicks (counter_cache from 3 visits)
      expect(page).to have_css("#url_#{url.id}_clicks_count", text: "3")
      # Unique countries
      expect(page).to have_css(".card p.text-3xl", text: "2")
      expect(page).to have_content("Jan 10, 2026")
      expect(page).to have_content("May 01, 2026")
    end
  end
end
