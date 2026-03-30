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
end
