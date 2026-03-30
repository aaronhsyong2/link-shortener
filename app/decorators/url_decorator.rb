class UrlDecorator < SimpleDelegator
  def display_title
    title.presence || "No title available"
  end

  def short_url(context)
    context.short_redirect_url(short_code: short_code)
  end

  def formatted_created_at
    created_at.strftime("%B %d, %Y at %H:%M")
  end
end
