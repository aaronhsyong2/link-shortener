FactoryBot.define do
  factory :url do
    target_url { "https://example.com" }
    title { "Example Domain" }
    clicks_count { 0 }
  end
end
