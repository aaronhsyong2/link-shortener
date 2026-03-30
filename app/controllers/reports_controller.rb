class ReportsController < ApplicationController
  def show
    @url = UrlDecorator.new(Url.find(params[:url_id]))
    @analytics = UrlAnalyticsQuery.new(@url)
  end
end
