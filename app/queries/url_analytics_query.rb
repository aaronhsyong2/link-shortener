class UrlAnalyticsQuery
  attr_reader :url

  def initialize(url)
    @url = url
  end

  def total_clicks
    url.clicks_count
  end

  def visits_by_country
    url.visits.group(:country).count.sort_by { |_, count| -count }
  end

  def visits_by_city
    url.visits.group(:city).count.sort_by { |_, count| -count }
  end

  def recent_visits(limit: 50)
    url.visits.order(visited_at: :desc).limit(limit)
  end
end
