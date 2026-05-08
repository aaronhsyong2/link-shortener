require "rails_helper"

RSpec.describe "Turbo Stream updates", type: :system do
  it "updates title in real time after async fetch" do
    visit root_path
    fill_in "Enter your URL", with: "https://example.com"
    click_button "Shorten URL"

    # Initially shows fetching state
    expect(page).to have_content("Fetching title...")

    # Simulate title fetch completing — triggers broadcast via after_update_commit
    url = Url.last
    url.update!(title: "Example Domain", title_fetched_at: Time.current)

    # Turbo Stream should replace title
    expect(page).to have_content("Example Domain", wait: 5)
  end

  it "shows initial click count on report page" do
    url = create(:url)
    create(:visit, url: url)
    url.reload

    visit url_report_path(url)

    expect(page).to have_css("#url_#{url.id}_clicks_count", text: "1")
  end
end
