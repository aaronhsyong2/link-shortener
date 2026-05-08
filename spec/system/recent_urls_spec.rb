require "rails_helper"

RSpec.describe "Recent URLs on homepage", type: :system do
  it "shows recently created URL in session" do
    visit root_path
    fill_in "Enter your URL", with: "https://example.com/first"
    click_button "Shorten URL"

    # Now on show page — navigate back to homepage
    expect(page).to have_content("URL Details")
    click_link "Shorten Another"

    expect(page).to have_css("table")
    expect(page).to have_content("example.com/first")
  end

  it "shows multiple recent URLs" do
    visit root_path
    fill_in "Enter your URL", with: "https://example.com/one"
    click_button "Shorten URL"
    click_link "Shorten Another"

    fill_in "Enter your URL", with: "https://example.com/two"
    click_button "Shorten URL"
    click_link "Shorten Another"

    expect(page).to have_content("example.com/one")
    expect(page).to have_content("example.com/two")
  end

  it "shows empty state when no URLs created" do
    visit root_path
    expect(page).to have_content("No URLs shortened yet")
  end
end
