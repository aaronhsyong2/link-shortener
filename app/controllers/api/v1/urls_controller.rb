module Api
  module V1
    class UrlsController < BaseController
      def create
        title = UrlMetadataService.call(url_params[:target_url])
        url = UrlShortenerService.call(
          target_url: url_params[:target_url],
          title: title
        )

        render json: url_response(url), status: :created
      end

      def show
        url = Url.find_by!(short_code: params[:short_code])
        render json: url_response(url)
      end

      private

      def url_params
        params.require(:url).permit(:target_url)
      end

      def url_response(url)
        {
          short_code: url.short_code,
          short_url: short_redirect_url(short_code: url.short_code),
          target_url: url.target_url,
          title: url.title,
          clicks_count: url.clicks_count,
          created_at: url.created_at.iso8601
        }
      end
    end
  end
end
