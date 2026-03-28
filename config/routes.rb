Rails.application.routes.draw do
  root "urls#new"

  resources :urls, only: %i[index show new create] do
    resource :report, only: :show
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Short URL redirect — must be last (catches /:short_code)
  get ":short_code" => "redirects#show", as: :short_redirect
end
