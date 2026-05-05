Rails.application.routes.draw do
  root "urls#new"

  resources :urls, only: %i[index show new create] do
    resource :report, only: :show
  end

  namespace :api do
    namespace :v1 do
      resources :urls, only: :create
      get "urls/:slug", to: "urls#show"
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Short URL redirect — must be last (catches /:slug)
  get ":slug" => "redirects#show", as: :short_redirect
end
