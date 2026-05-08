require "rails_helper"

RSpec.describe "Navigation", type: :system do
  it "navigates from homepage to All URLs" do
    visit root_path
    click_link "All URLs"

    expect(page).to have_css("h1", text: "All URLs")
  end

  it "shows All URLs listing with created URLs" do
    create(:url, title: "Test Site", target_url: "https://test.com")
    visit urls_path

    expect(page).to have_content("Test Site")
    expect(page).to have_content("test.com")
    expect(page).to have_link("Details")
    expect(page).to have_link("Report")
  end

  it "navigates from show page to report via View Report" do
    url = create(:url)
    visit url_path(url)
    click_link "View Report"

    expect(page).to have_content("Usage Report")
  end

  it "navigates from show page back to homepage via Shorten Another" do
    url = create(:url)
    visit url_path(url)
    click_link "Shorten Another"

    expect(page).to have_content("Shorten your URL")
  end

  it "navigates from show page to All URLs via action bar" do
    url = create(:url)
    visit url_path(url)
    # Two "All URLs" links exist (navbar + action bar) — use last one
    all(:link, "All URLs").last.click

    expect(page).to have_css("h1", text: "All URLs")
  end

  it "shows empty state when no URLs exist" do
    visit urls_path

    expect(page).to have_content("No URLs shortened yet")
    expect(page).to have_link("Shorten your first URL")
  end

  it "navbar Shorten link goes to homepage" do
    visit urls_path
    within("nav") { click_link "Shorten" }

    expect(page).to have_content("Shorten your URL")
  end
end
