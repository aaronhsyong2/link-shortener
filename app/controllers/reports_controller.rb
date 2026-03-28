class ReportsController < ApplicationController
  def show
    @url = Url.find(params[:url_id])
    @visits = @url.visits.order(visited_at: :desc)
    @visits_by_country = @url.visits.group(:country).count
    @visits_by_city = @url.visits.group(:city).count
    @total_clicks = @url.clicks_count
  end
end
