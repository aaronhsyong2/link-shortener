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
    ua_data = parse_user_agent(request.user_agent)

    url.visits.create!(
      ip_address: request.remote_ip,
      country: geo[:country],
      city: geo[:city],
      user_agent: request.user_agent.presence&.truncate(512, omission: ""),
      referer: request.referer.presence&.truncate(2048, omission: ""),
      referer_domain: extract_referer_domain(request.referer),
      browser: ua_data[:browser],
      os: ua_data[:os],
      device_type: ua_data[:device_type],
      is_bot: ua_data[:is_bot],
      visited_at: Time.current
    )

    url.increment!(:clicks_count)
  end

  def parse_user_agent(ua_string)
    return { browser: nil, os: nil, device_type: nil, is_bot: false } if ua_string.blank?

    b = Browser.new(ua_string)
    {
      browser: (b.bot? ? b.bot.name : b.name).truncate(128, omission: ""),
      os: b.platform.name.truncate(128, omission: ""),
      device_type: detect_device_type(b),
      is_bot: b.bot?
    }
  end

  def detect_device_type(b)
    if b.device.mobile? then "mobile"
    elsif b.device.tablet? then "tablet"
    else "desktop"
    end
  end

  def extract_referer_domain(referer)
    return nil if referer.blank?
    URI.parse(referer).host
  rescue URI::InvalidURIError
    nil
  end
end
