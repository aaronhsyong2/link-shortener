class VisitDecorator < SimpleDelegator
  def formatted_timestamp
    visited_at.strftime("%Y-%m-%d %H:%M:%S UTC")
  end

  def iso_timestamp
    visited_at.iso8601
  end

  def masked_ip
    parts = ip_address.split(".")
    return ip_address unless parts.length == 4
    "#{parts[0]}.#{parts[1]}.***. ***"
  end

  def display_location
    [ city, country ].reject { |v| v == "Unknown" }.join(", ").presence || "Unknown"
  end

  def display_browser
    browser.presence || "Unknown"
  end

  def display_os
    os.presence || "Unknown"
  end

  def display_device_type
    device_type&.capitalize || "Unknown"
  end

  def masked_referer
    referer_domain.presence || "Direct"
  end

  def bot_indicator
    is_bot ? "Bot" : "Human"
  end
end
