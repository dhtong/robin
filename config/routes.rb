Rails.application.routes.draw do
  namespace :slack do
    resources :auth, only: :index
    resources :events, only: :create do
      collection do
        post 'ping'
      end
    end
    resources :interactions, only: :create
  end

  namespace :telegram do
    resources :events, only: :create
  end

  namespace :pagerduty do
    resources :auth, only: :index
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
