require "rails_helper"

RSpec.describe "Report Tabs", type: :system do
  it "switches between tabs" do
    url = create(:url)
    create(:visit, url: url, browser: "Chrome", os: "macOS", device_type: "desktop",
           country: "US", city: "NYC", visited_at: 1.hour.ago)

    visit url_report_path(url)

    # Overview tab visible by default
    overview_panel = find("[data-tabs-target='panel'][data-tab='overview']", visible: true)
    expect(overview_panel).not_to match_css("[hidden]")

    # Switch to Devices tab
    click_link "Devices"
    devices_panel = find("[data-tabs-target='panel'][data-tab='devices']", visible: true)
    expect(devices_panel).not_to match_css("[hidden]")

    # Overview now hidden
    overview_panel = find("[data-tabs-target='panel'][data-tab='overview']", visible: false)
    expect(overview_panel).to match_css("[hidden]")
  end

  it "switches to Traffic Sources tab" do
    url = create(:url)
    create(:visit, url: url, referer_domain: "example.com", country: "MY", city: "KL")

    visit url_report_path(url)
    click_link "Traffic Sources"

    traffic_panel = find("[data-tabs-target='panel'][data-tab='traffic']", visible: true)
    expect(traffic_panel).to have_content("example.com")
  end
end
