Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  get "homes/index"
  resources :items, only: [:index]
  resources :categories, only: [:show, :index]
  resources :brands, only: [:show, :index]
  
  # Cart routes
  resources :carts, only: [:show, :new] do
    member do
      post :add_item
      delete :remove_item
      patch :update_item_quantity
    end
  end
  
  # Shorthand routes for cart actions
  post 'cart/add_item', to: 'carts#add_item', as: :cart_add_item
  delete 'cart/remove_item', to: 'carts#remove_item', as: :cart_remove_item
  patch 'cart/update_item', to: 'carts#update_item_quantity', as: :cart_update_item
  
  # Defines the root path route ("/")
  root "homes#index"
end
