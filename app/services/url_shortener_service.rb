class UrlShortenerService
  def self.call(target_url:, title: nil)
    Url.create!(
      target_url: target_url,
      title: title
    )
  end
end
