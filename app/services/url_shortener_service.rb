class UrlShortenerService
  CHARSET = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
  DEFAULT_LENGTH = 6
  MAX_LENGTH = 15
  MAX_RETRIES = 10

  def initialize(length: DEFAULT_LENGTH)
    @length = [length, MAX_LENGTH].min
  end

  def call(target_url:, title: nil)
    short_code = generate_unique_code
    Url.create!(
      target_url: target_url,
      short_code: short_code,
      title: title
    )
  end

  private

  def generate_unique_code
    MAX_RETRIES.times do
      code = Array.new(@length) { CHARSET.sample }.join
      return code unless Url.exists?(short_code: code)
    end

    raise "Failed to generate unique short code after #{MAX_RETRIES} attempts"
  end
end
