module UrlsHelper
  def safe_url(url)
    uri = URI.parse(url)
    uri.scheme.in?(%w[http https]) ? url : "#"
  rescue URI::InvalidURIError
    "#"
  end
end
