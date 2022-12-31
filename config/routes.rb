Rails.application.routes.draw do
  namespace :slack do
    resources :events, only: :create
    resources :interactions, only: :create
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
