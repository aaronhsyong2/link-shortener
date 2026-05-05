class UrlDecorator < SimpleDelegator
  def display_title
    return "Fetching title..." if title.nil? && created_at > 1.minute.ago
    title.presence || "No title available"
  end

  def short_url(context)
    context.short_redirect_url(slug: slug)
  end

  def formatted_created_at
    created_at.strftime("%B %d, %Y at %H:%M")
  end
end
