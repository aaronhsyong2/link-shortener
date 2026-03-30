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
  end

  # POST /urls
  def create
    @url = UrlShortenerService.call(target_url: url_params[:target_url])
    FetchTitleJob.perform_later(@url.id)

    redirect_to @url, notice: "Short URL created successfully."
  rescue ActiveRecord::RecordInvalid => e
    @url = e.record
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
end
