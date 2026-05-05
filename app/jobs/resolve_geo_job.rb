class ResolveGeoJob < ApplicationJob
  queue_as :default

  def perform(visit_id)
    visit = Visit.find_by(id: visit_id)
    return unless visit
    return if visit.country.present?

    geo = GeolocationService.call(visit.ip_address)
    visit.update!(country: geo[:country], city: geo[:city])
  rescue StandardError => e
    visit&.update_columns(country: "Unknown", city: "Unknown")
    Rails.logger.warn("ResolveGeoJob failed for visit_id=#{visit_id}: #{e.message}")
  end
end
