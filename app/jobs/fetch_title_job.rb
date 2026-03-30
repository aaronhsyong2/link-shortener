class FetchTitleJob < ApplicationJob
  queue_as :default

  def perform(url_id)
    url = Url.find_by(id: url_id)
    return unless url
    return if url.title.present?

    title = UrlMetadataService.call(url.target_url)
    url.update!(title: title) if title.present?
  end
end
