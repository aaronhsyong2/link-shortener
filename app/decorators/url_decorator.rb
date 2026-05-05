class UrlDecorator < SimpleDelegator
  def display_title
    return title if title.present?
    title_fetched_at? ? "No title available" : "Fetching title..."
  end

  def short_url(context)
    context.short_redirect_url(slug: slug)
  end

  def formatted_created_at
    created_at.strftime("%B %d, %Y at %H:%M")
  end
end
