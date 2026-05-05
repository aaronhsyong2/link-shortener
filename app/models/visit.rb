class Visit < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :url, counter_cache: :clicks_count

  after_create_commit :broadcast_new_visit
  after_update_commit :broadcast_geo_update, if: -> { saved_change_to_country? || saved_change_to_city? }

  private

  def broadcast_new_visit
    broadcast_prepend_later_to(
      url,
      target: "visits",
      partial: "reports/visit_row",
      locals: { visit: self }
    )
    broadcast_replace_later_to(
      url,
      target: "url_#{url_id}_clicks_count",
      partial: "reports/clicks_count",
      locals: { url: url }
    )
  end

  def broadcast_geo_update
    broadcast_replace_later_to(
      url,
      target: "visit_#{id}",
      partial: "reports/visit_row",
      locals: { visit: self }
    )
  end
end
