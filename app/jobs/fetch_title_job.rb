class FetchTitleJob < ApplicationJob
  queue_as :default

  def perform(url_id, target_url)
    # HTTP first — no DB connection held during network I/O
    title = UrlMetadataService.call(target_url)

    url = Url.find_by(id: url_id)
    return unless url
    return if url.title.present?

    url.update!(title: title.presence, title_fetched_at: Time.current)
  rescue StandardError => e
    Url.where(id: url_id).update_all(title_fetched_at: Time.current)
    Rails.logger.warn("FetchTitleJob failed for url_id=#{url_id}: #{e.message}")
  end
end
