FactoryBot.define do
  factory :visit do
    url
    ip_address { "8.8.8.8" }
    country { "US" }
    city { "Mountain View" }
    visited_at { Time.current }
  end
end
