FactoryBot.define do
  factory :url do
    target_url { "https://example.com" }
    short_code { SecureRandom.alphanumeric(6) }
    title { "Example Domain" }
    clicks_count { 0 }
  end
end
