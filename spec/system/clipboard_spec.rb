require "rails_helper"

RSpec.describe "Clipboard copy button", type: :system do
  it "changes button text to Copied! on click" do
    url = create(:url)
    visit url_path(url)

    copy_button = find("button", text: "Copy")
    # Stub clipboard API to avoid permission issues in headless Chrome
    page.execute_script("navigator.clipboard.writeText = (text) => Promise.resolve()")
    copy_button.click

    expect(page).to have_button("Copied!")
    # Reverts after 2 seconds
    expect(page).to have_button("Copy", wait: 3)
  end
end
