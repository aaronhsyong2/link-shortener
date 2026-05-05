class FetchTitleJob < ApplicationJob
  queue_as :default

  def perform(url_id)
    url = Url.find_by(id: url_id)
    return unless url
    return if url.title.present?

    title = UrlMetadataService.call(url.target_url)
    url.update!(title: title.presence, title_fetched_at: Time.current)
  rescue StandardError => e
    url&.update_column(:title_fetched_at, Time.current)
    Rails.logger.warn("FetchTitleJob failed for url_id=#{url_id}: #{e.message}")
  end
end
