Vyapari::Engine.routes.draw do

  mount Usman::Engine => "/"

  namespace :admin do

    get   '/dashboard',         to: "dashboard#index",  as:   :dashboard
    
    # Admin Routes
    resources :countries
    resources :regions
    resources :exchange_rates

    # Stock Management Routes
    resources :suppliers
    resources :stores
    resources :brands
    
    resources :categories do
      member do
        put :update_status, as:  :update_status
      end
    end

   end


end
