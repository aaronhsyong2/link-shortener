class Url < ApplicationRecord
  SQIDS = Sqids.new(
    min_length: 4,
    alphabet: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  )

  has_many :visits, dependent: :destroy

  validates :target_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid HTTP or HTTPS URL" }

  def slug
    raise "Cannot generate slug for unsaved record" unless persisted?
    SQIDS.encode([id])
  end

  def self.from_slug(slug)
    raise ActiveRecord::RecordNotFound, "Invalid slug" if slug.blank?
    ids = SQIDS.decode(slug)
    raise ActiveRecord::RecordNotFound, "Invalid slug" if ids.empty?
    find(ids.first)
  end
end
