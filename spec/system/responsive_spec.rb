require "rails_helper"

RSpec.describe "Responsive layout", type: :system do
  it "renders homepage correctly on mobile viewport" do
    visit root_path
    page.driver.browser.manage.window.resize_to(375, 812)

    expect(page).to have_content("Shorten your URL")
    expect(page).to have_field("Enter your URL")
    expect(page).to have_button("Shorten URL")
  end

  it "renders All URLs table on mobile viewport" do
    create(:url, title: "Mobile Test")
    visit urls_path
    page.driver.browser.manage.window.resize_to(375, 812)

    expect(page).to have_content("All URLs")
    expect(page).to have_content("Mobile Test")
  end

  it "renders report page on mobile viewport" do
    url = create(:url)
    create(:visit, url: url)
    visit url_report_path(url)
    page.driver.browser.manage.window.resize_to(375, 812)

    expect(page).to have_content("Usage Report")
    expect(page).to have_css("p", text: /total clicks/i)
  end

  it "navbar links are visible on desktop" do
    visit root_path
    page.driver.browser.manage.window.resize_to(1280, 800)

    within("nav") do
      expect(page).to have_link("Shorten")
      expect(page).to have_link("All URLs")
      expect(page).to have_css("[aria-label='Toggle dark mode']")
    end
  end
end
