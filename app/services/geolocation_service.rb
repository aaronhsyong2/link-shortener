require "net/http"
require "ipaddr"

class GeolocationService
  API_URL = "https://ipinfo.io".freeze
  TIMEOUT_SECONDS = 3

  def self.instance(api_token: nil)
    @instance ||= new(api_token: api_token)
  end

  def self.call(...)
    instance.call(...)
  end

  def initialize(api_token: nil)
    @api_token = api_token || ENV["IPINFO_TOKEN"]
  end

  def call(ip_address)
    return default_result if private_ip?(ip_address)

    fetch_geolocation(ip_address)
  rescue SocketError, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout, JSON::ParserError
    default_result
  end

  private

  def fetch_geolocation(ip_address)
    uri = URI("#{API_URL}/#{ip_address}/json")
    uri.query = URI.encode_www_form(token: @api_token) if @api_token

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = TIMEOUT_SECONDS
    http.read_timeout = TIMEOUT_SECONDS

    response = http.request(Net::HTTP::Get.new(uri))
    return default_result unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    {
      country: data["country"] || "Unknown",
      city: data["city"] || "Unknown"
    }
  end

  def private_ip?(ip_address)
    return true if ip_address.blank?

    ip = IPAddr.new(ip_address)
    ip.loopback? || ip.private? || ip.link_local?
  rescue IPAddr::InvalidAddressError
    true
  end

  def default_result
    { country: "Unknown", city: "Unknown" }
  end
end
