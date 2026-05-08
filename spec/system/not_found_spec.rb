require "rails_helper"

RSpec.describe "404 page", type: :system do
  it "shows 404 page for nonexistent slug" do
    visit "/nonexistent-slug-xyz"

    expect(page).to have_content("404")
    expect(page).to have_content("Page not found")
    expect(page).to have_link("Shorten a URL")
  end

  it "links back to homepage from 404" do
    visit "/nonexistent-slug-xyz"
    click_link "Shorten a URL"

    expect(page).to have_content("Shorten your URL")
  end
end
