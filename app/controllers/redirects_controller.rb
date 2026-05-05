class RedirectsController < ApplicationController
  def show
    url = Url.from_slug(params[:slug])

    track_visit(url)

    redirect_to url.target_url, allow_other_host: true # brakeman:disable:Redirect -- intentional: URL shortener must redirect to user-provided URLs, validated as http/https in model
  rescue ActiveRecord::RecordNotFound
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end

  private

  def track_visit(url)
    geo = GeolocationService.call(request.remote_ip)

    url.visits.create!(
      ip_address: request.remote_ip,
      country: geo[:country],
      city: geo[:city],
      visited_at: Time.current
    )

    url.increment!(:clicks_count)
  end
end
