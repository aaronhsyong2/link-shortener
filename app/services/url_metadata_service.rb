require "net/http"

class UrlMetadataService
  TIMEOUT_SECONDS = 5
  MAX_READ_BYTES = 10_240

  def self.instance
    @instance ||= new
  end

  def self.call(...)
    instance.call(...)
  end

  def call(target_url)
    uri = URI.parse(target_url)
    return nil unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    fetch_title(uri)
  rescue URI::InvalidURIError, SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout
    nil
  end

  private

  def fetch_title(uri)
    response = make_request(uri)
    return nil unless response.is_a?(Net::HTTPSuccess)
    return nil unless response.content_type&.include?("text/html")

    parse_title(response.body)
  end

  def make_request(uri, redirect_limit: 3)
    return nil if redirect_limit <= 0

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = TIMEOUT_SECONDS
    http.read_timeout = TIMEOUT_SECONDS

    request = Net::HTTP::Get.new(uri)
    request["User-Agent"] = "LinkShortener/1.0"

    response = http.request(request)

    case response
    when Net::HTTPRedirection
      redirect_uri = URI.parse(response["location"])
      redirect_uri = URI.join("#{uri.scheme}://#{uri.host}", response["location"]) unless redirect_uri.host
      make_request(redirect_uri, redirect_limit: redirect_limit - 1)
    else
      response
    end
  end

  def parse_title(html)
    doc = Nokogiri::HTML(html)
    doc.at_css("title")&.text&.strip&.truncate(255)
  end
end
