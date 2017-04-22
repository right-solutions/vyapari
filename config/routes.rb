Vyapari::Engine.routes.draw do

  namespace :admin do

    get   '/dashboard',         to: "dashboard#index",  as:   :dashboard
    
    # Admin Routes
    resources :countries
    resources :regions
    resources :exchange_rates

    # Stock Management Routes
    resources :suppliers
    resources :stores do

      member do
        put :update_status, as:  :update_status
      end
      
      resources :terminals do
        member do
          put :update_status, as:  :update_status
        end
      end
    end
    
    resources :brands do
      member do
        put :update_status, as:  :update_status
        put :mark_as_featured, as:  :mark_as_featured
        put :remove_from_featured, as:  :remove_from_featured
      end
    end

    resources :categories do
      member do
        put :update_status, as:  :update_status
        put :mark_as_featured, as:  :mark_as_featured
        put :remove_from_featured, as:  :remove_from_featured
        put :make_parent, as:  :make_parent
      end
    end

    resources :products do
      member do
        put :update_status, as:  :update_status
        put :mark_as_featured, as:  :mark_as_featured
        put :remove_from_featured, as:  :remove_from_featured
      end
    end

  end

  get '/users/dashboard', to: "user_dashboard#index",  as: :user_dashboard

  namespace :store_manager do

    scope '/:store_id' do
      get '/dashboard', to: "dashboard#index",  as: :dashboard
      get '/reports/sales', to: "reports/sales#index", as: :sales_report
      get '/reports/invoices', to: "reports/invoices#index", as: :invoices_report
      get '/reports/stock', to: "reports/stock#index", as: :stock_report
      resources :terminals
      resources :stock_entries
      resources :stock_bundles do
        member do
          get :download_original_file, as:  :download_original_file
          get :download_error_file, as:  :download_error_file
        end
      end
    end

  end

  namespace :terminal_staff do
    
    scope '/:terminal_id' do
      get   '/dashboard',         to: "dashboard#index",  as:   :dashboard
      get   '/search',            to: "dashboard#search",  as:  :dashboard_search
      resources :invoices do
        resources :line_items
      end
    end

  end

  mount Usman::Engine => "/"

end
