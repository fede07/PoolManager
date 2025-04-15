Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  get "matches/index"
  get "matches/show"
  get "matches/create"
  get "matches/update"
  get "matches/destroy"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    get "/players/me", to: "players#me"
    patch "/players/me/", to: "players#update_me"
    put "/players/me/", to: "players#update_me"
    resources :players, only: [ :index, :create, :update, :destroy ]
    resources :matches, only: [ :index, :show, :create, :update, :destroy ]

    post "auth/register", to: "auth#register"
    delete "/players", to: "players#destroy"
    post "/players", to: "players#create"
    get "/players", to: "players#index"

    post "/matches", to: "matches#create"
    get "/matches", to: "matches#index"
    get "/matches/:id", to: "matches#show"
    patch "/matches/:id", to: "matches#update"
    put "/matches/:id", to: "matches#update"
    delete "/matches/:id", to: "matches#destroy"

    post "/uploads", to: "uploads#generate_presigned_url"
  end
end
