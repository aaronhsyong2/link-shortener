class Url < ApplicationRecord
  include Turbo::Broadcastable

  SQIDS = Sqids.new(
    min_length: 4,
    alphabet: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  )

  has_many :visits, dependent: :destroy

  after_update_commit :broadcast_title, if: -> { saved_change_to_title? && title.present? }

  validates :target_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid HTTP or HTTPS URL" }
  validate :reject_embedded_credentials
  validate :reject_private_ip
  validate :reject_self_referential

  def slug
    raise "Cannot generate slug for unsaved record" unless persisted?
    SQIDS.encode([ id ])
  end

  def self.from_slug(slug)
    raise ActiveRecord::RecordNotFound, "Invalid slug" if slug.blank?
    ids = SQIDS.decode(slug)
    raise ActiveRecord::RecordNotFound, "Invalid slug" if ids.empty?
    find(ids.first)
  end

  private

  def broadcast_title
    broadcast_replace_to(
      "url_titles",
      target: "url_#{id}_title",
      partial: "urls/title",
      locals: { url: self }
    )
  end

  def reject_embedded_credentials
    return if target_url.blank?

    uri = URI.parse(target_url)
    if uri.userinfo.present?
      errors.add(:target_url, "must not contain embedded credentials")
    end
  rescue URI::InvalidURIError
    # format validation handles malformed URIs
  end

  def reject_private_ip
    return if target_url.blank?

    uri = URI.parse(target_url)
    return if uri.host.blank?

    ip = IPAddr.new(uri.host)
    if ip.loopback? || ip.private? || ip.link_local?
      errors.add(:target_url, "must not point to a private or localhost address")
    end
  rescue URI::InvalidURIError
    # format validation handles malformed URIs
  rescue IPAddr::InvalidAddressError
    # host is a domain name — allowed
  end

  def reject_self_referential
    return if target_url.blank?

    uri = URI.parse(target_url)
    return if uri.host.blank?

    shortener_hosts = ENV.fetch("SHORTENER_HOSTS", "").split(",").map(&:strip).reject(&:blank?)
    return if shortener_hosts.empty?

    if shortener_hosts.any? { |host| uri.host.downcase == host.downcase }
      errors.add(:target_url, "must not point back to this shortener")
    end
  rescue URI::InvalidURIError
    # format validation handles malformed URIs
  end
end
