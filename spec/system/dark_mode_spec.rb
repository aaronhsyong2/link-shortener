require "rails_helper"

RSpec.describe "Dark mode toggle", type: :system do
  def ensure_light_mode
    page.execute_script("localStorage.setItem('theme', 'light'); document.documentElement.classList.remove('dark')")
  end

  it "toggles dark class on html element" do
    visit root_path
    ensure_light_mode

    html = find("html")
    expect(html[:class]).not_to include("dark")

    find("[aria-label='Toggle dark mode']").click
    expect(html[:class]).to include("dark")

    find("[aria-label='Toggle dark mode']").click
    expect(html[:class]).not_to include("dark")
  end

  it "persists preference across page loads via localStorage" do
    visit root_path
    ensure_light_mode

    find("[aria-label='Toggle dark mode']").click
    expect(find("html")[:class]).to include("dark")

    visit urls_path
    expect(find("html")[:class]).to include("dark")
  end

  it "respects localStorage theme on page load" do
    visit root_path
    page.execute_script("localStorage.setItem('theme', 'dark')")

    visit root_path
    expect(find("html")[:class]).to include("dark")

    page.execute_script("localStorage.setItem('theme', 'light')")
    visit root_path
    expect(find("html")[:class]).not_to include("dark")
  end
end
