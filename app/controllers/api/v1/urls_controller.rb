module Api
  module V1
    class UrlsController < BaseController
      def create
        url = UrlShortenerService.call(target_url: url_params[:target_url])
        FetchTitleJob.perform_later(url.id, url.target_url)

        render json: url_response(url), status: :created
      end

      def show
        url = Url.from_slug(params[:slug])
        render json: url_response(url)
      end

      private

      def url_params
        params.require(:url).permit(:target_url)
      end

      def url_response(url)
        {
          slug: url.slug,
          short_url: short_redirect_url(slug: url.slug),
          target_url: url.target_url,
          title: url.title,
          clicks_count: url.clicks_count,
          created_at: url.created_at.iso8601
        }
      end
    end
  end
end
