class Url < ApplicationRecord
  has_many :visits, dependent: :destroy

  validates :target_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid HTTP or HTTPS URL" }
  validates :short_code, presence: true, uniqueness: true, length: { maximum: 15 }
end
