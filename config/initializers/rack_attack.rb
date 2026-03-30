class Rack::Attack
  # 5 URL creations/min per IP (metadata fetch blocks a thread for up to 5s)
  throttle("urls/create", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/urls" && req.post?
  end

  throttle("api/create", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/api/v1/urls" && req.post?
  end

  throttle("api/read", limit: 30, period: 1.minute) do |req|
    req.ip if req.get? && req.path.start_with?("/api/")
  end

  # 100 redirects/min per IP (higher limit for shared IPs)
  throttle("redirects/show", limit: 100, period: 1.minute) do |req|
    req.ip if req.get? && req.path.match?(%r{\A/[a-zA-Z0-9]+\z})
  end

  # Drop scanner noise — saves resources on free tier
  blocklist("block/scan-noise") do |req|
    req.path.match?(%r{\.(php|asp|aspx|jsp|cgi)$}i)
  end

  self.throttled_responder = lambda do |req|
    if req.path.start_with?("/api/")
      [ 429, { "Content-Type" => "application/json" }, [ { error: "Rate limit exceeded" }.to_json ] ]
    else
      [ 429, { "Content-Type" => "text/html" }, [ File.read(Rails.root.join("public/429.html")) ] ]
    end
  rescue Errno::ENOENT
    [ 429, { "Content-Type" => "text/plain" }, [ "Rate limit exceeded. Please try again later." ] ]
  end
end
