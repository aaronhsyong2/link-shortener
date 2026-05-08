require "rails_helper"

RSpec.describe "URL shortening flow", type: :system do
  describe "golden path" do
    it "creates a short URL, redirects through it, and shows analytics" do
      # Step 1: Visit homepage and shorten a URL
      visit root_path
      fill_in "Enter your URL", with: "https://example.com/a-very-long-path"
      click_button "Shorten URL"

      # Step 2: Verify show page with short URL details
      expect(page).to have_content("URL Details")
      expect(page).to have_css("label", text: /short url/i)
      expect(page).to have_css("label", text: /target url/i)
      expect(page).to have_content("https://example.com/a-very-long-path")

      short_url_code = find("code").text.strip
      slug = short_url_code.split("/").last

      # Step 3: Follow the short URL — should redirect to target
      visit "/#{slug}"
      expect(current_url).to eq("https://example.com/a-very-long-path")

      # Step 4: View the report page
      visit url_report_path(Url.last)
      expect(page).to have_content("Usage Report")
      expect(page).to have_css("p", text: /total clicks/i)
      expect(page).to have_css("p", text: "1")
    end
  end

  describe "error path" do
    it "shows validation errors for invalid URL" do
      visit root_path
      # Change input type to text to bypass browser-level url validation
      page.execute_script("const el = document.querySelector('input[type=url]'); el.type = 'text'; el.removeAttribute('required')")
      fill_in "Enter your URL", with: "not-a-valid-url"
      click_button "Shorten URL"

      expect(page).to have_content("error")
      expect(page).to have_content("must be a valid HTTP or HTTPS URL")
      expect(page).to have_field("Enter your URL")
    end

    it "shows validation errors for blank URL" do
      visit root_path
      # Remove required attr to bypass browser-level validation
      page.execute_script("document.querySelector('input[type=url]').removeAttribute('required')")
      click_button "Shorten URL"

      expect(page).to have_content("error")
      expect(page).to have_content("can't be blank")
    end
  end
end
