class ResolveGeoJob < ApplicationJob
  queue_as :default

  def perform(visit_id, ip_address)
    # HTTP first — no DB connection held during network I/O
    geo = GeolocationService.call(ip_address)

    visit = Visit.find_by(id: visit_id)
    return unless visit
    return if visit.country.present?

    visit.update!(country: geo[:country], city: geo[:city])
  rescue StandardError => e
    Visit.where(id: visit_id).update_all(country: "Unknown", city: "Unknown")
    Rails.logger.warn("ResolveGeoJob failed for visit_id=#{visit_id}: #{e.message}")
  end
end
