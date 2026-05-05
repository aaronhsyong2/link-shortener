class UrlsController < ApplicationController
  before_action :set_url, only: %i[ show ]

  # GET /urls
  def index
    @urls = Url.order(created_at: :desc).page(params[:page]).per(20)
  end

  # GET /urls/1
  def show
  end

  # GET /urls/new
  def new
    @url = Url.new
    @recent_urls = load_recent_urls
  end

  # POST /urls
  def create
    @url = UrlShortenerService.call(target_url: url_params[:target_url])
    FetchTitleJob.perform_later(@url.id)
    track_recent_url(@url.id)

    redirect_to @url, notice: "Short URL created successfully."
  rescue ActiveRecord::RecordInvalid => e
    @url = e.record
    @recent_urls = load_recent_urls
    render :new, status: :unprocessable_entity
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_url
      @url = UrlDecorator.new(Url.find(params[:id]))
    end

    # Only allow a list of trusted parameters through.
    def url_params
      params.require(:url).permit(:target_url)
    end

    def track_recent_url(url_id)
      ids = session[:recent_url_ids] || []
      ids.unshift(url_id)
      session[:recent_url_ids] = ids.uniq.first(50)
    end

    def load_recent_urls
      ids = (session[:recent_url_ids] || []).first(10)
      return [] if ids.empty?

      urls_by_id = Url.where(id: ids).index_by(&:id)
      ids.filter_map { |id| urls_by_id[id] }
    end
end
