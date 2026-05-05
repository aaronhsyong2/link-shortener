FactoryBot.define do
  factory :visit do
    url
    ip_address { "8.8.8.8" }
    country { "US" }
    city { "Mountain View" }
    user_agent { "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
    referer { "https://google.com/search?q=test" }
    referer_domain { "google.com" }
    browser { "Chrome" }
    os { "macOS" }
    device_type { "desktop" }
    is_bot { false }
    visited_at { Time.current }
  end
end
