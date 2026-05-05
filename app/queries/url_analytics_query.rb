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
    url.visits.order(visited_at: :desc).limit(limit).map { |v| VisitDecorator.new(v) }
  end

  def daily_series(days: 30, include_bots: false)
    start_date = (days - 1).days.ago.to_date
    visits = filtered_visits(include_bots)
      .where(visited_at: start_date.beginning_of_day..)
      .group("DATE(visited_at)")
      .count

    (start_date..Date.today).map { |date| [ date, visits[date] || 0 ] }
  end

  def hourly_distribution(include_bots: false)
    counts = filtered_visits(include_bots)
      .group("EXTRACT(HOUR FROM visited_at)::integer")
      .count

    (0..23).to_h { |hour| [ hour, counts[hour] || 0 ] }
  end

  def first_click(include_bots: false)
    filtered_visits(include_bots).minimum(:visited_at)
  end

  def last_click(include_bots: false)
    filtered_visits(include_bots).maximum(:visited_at)
  end

  def visits_by_browser(include_bots: false)
    grouped_count(:browser, include_bots)
  end

  def visits_by_os(include_bots: false)
    grouped_count(:os, include_bots)
  end

  def visits_by_device_type(include_bots: false)
    grouped_count(:device_type, include_bots)
  end

  def visits_by_referer_domain(include_bots: false)
    grouped_count(:referer_domain, include_bots)
  end

  private

  def filtered_visits(include_bots)
    scope = url.visits
    scope = scope.where(is_bot: false) unless include_bots
    scope
  end

  def grouped_count(column, include_bots)
    filtered_visits(include_bots).group(column).count.sort_by { |_, count| -count }
  end
end
