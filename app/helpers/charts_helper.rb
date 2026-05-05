module ChartsHelper
  # Chart.js library options for consistent dark-mode-compatible styling
  def chart_library_options
    {
      scales: {
        x: {
          grid: { color: "rgba(156,163,175,0.2)" },
          ticks: { color: "rgba(156,163,175,0.8)" }
        },
        y: {
          grid: { color: "rgba(156,163,175,0.2)" },
          ticks: { color: "rgba(156,163,175,0.8)" },
          beginAtZero: true
        }
      },
      plugins: {
        legend: { labels: { color: "rgba(156,163,175,0.9)" } }
      }
    }
  end

  def pie_chart_library_options
    {
      plugins: {
        legend: { labels: { color: "rgba(156,163,175,0.9)" } }
      }
    }
  end
end
