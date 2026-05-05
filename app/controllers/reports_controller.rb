class ReportsController < ApplicationController
  def show
    @url = UrlDecorator.new(Url.find(params[:url_id]))
    @analytics = UrlAnalyticsQuery.new(@url)
    @recent_visits_page = @url.visits
      .where(is_bot: false)
      .order(visited_at: :desc)
      .page(params[:page])
      .per(25)
    @recent_visits = @recent_visits_page.map { |v| VisitDecorator.new(v) }
  end
end
