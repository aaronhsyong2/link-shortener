class Rack::Attack
  # 5 URL creations/min per IP (metadata fetch blocks a thread for up to 5s)
  throttle("urls/create", limit: 5, period: 1.minute) do |req|
    req.ip if req.path == "/urls" && req.post?
  end

  # 100 redirects/min per IP (higher limit for shared IPs)
  throttle("redirects/show", limit: 100, period: 1.minute) do |req|
    req.ip if req.get? && req.path.match?(%r{\A/[a-zA-Z0-9]+\z})
  end

  # Drop scanner noise — saves resources on free tier
  blocklist("block/scan-noise") do |req|
    req.path.match?(%r{\.(php|asp|aspx|jsp|cgi)$}i)
  end

  self.throttled_responder = lambda do |_req|
    [ 429, { "Content-Type" => "text/html" }, [ File.read(Rails.root.join("public/429.html")) ] ]
  rescue Errno::ENOENT
    [ 429, { "Content-Type" => "text/plain" }, [ "Rate limit exceeded. Please try again later." ] ]
  end
end
