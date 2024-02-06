Rails.application.routes.draw do
#   devise_for :views
#   devise_for :users
#   get "home/index"
#   root to: "home#index"
# end
# Rails.application.routes.draw do
  # devise_for :users
  devise_for :users do
    delete '/users/sign_out' => 'devise/sessions#destroy'
  end
  devise_for :views
  get "home/index"
  root to: "home#index"

  resources :sales, only: [:index, :show] do
    get 'all', to: 'sales#all', on: :collection
  end

  resources :customers, only: [:new, :create, :edit, :update, :show, :index, :destroy]
  resources :reports, only: [:index, :show, :edit, :update]
  resources :orders, only: [:new, :create, :update, :show, :destroy] do
    collection do
      get 'new/:items', :action => 'new', :as => 'item_to_be_added_to'
      get 'edit/:items', :action => 'new_customer', :as => 'new_customer_for'
      delete 'remove/:items, :item', :action => 'remove_item', :as => 'remove_item_from'
    end
    resources :receipts, only: [:new], defaults: { format: :pdf }
    resources :payments, only: [:new, :create]
    resources :items, only: [:new, :create, :destroy]
  end
  resources :payments do
    collection do
      get 'new/:items, :customer', :action => 'new_order_payment', :as => 'new_order'
      get 'new/:items', :action => 'new_order_payment', :as => 'new_order_without_customer'
    end
  end

  resources :items, only: [:create]
  resources :catalogue, only: [:index]
  resources :suppliers, only: [:index, :new, :create, :show, :edit, :update]

  namespace :catalogue do
    resources :suppliers, only: [:index, :new, :create, :show] do
      resources :products, only: [:index, :new, :create, :edit, :update, :destroy, :show] do
        resources :variants, only: [:create, :edit, :update, :destroy, :show] do
          get :print, on: :member
        end
        resource :variant do
          collection do
            get "new/:variant_attributes", :action => 'new', :as => 'new', :defaults => { :variant_attributes => "" }
          end
        end
        resources :product_attributes, only: [:new, :create]
        resources :product_attribute_types, only: [:index, :new, :create, :destroy]
      end
    end
    resources :variants do
      collection do
        get 'index/:results, :query_params', :action => 'index', :as => 'index'
        post 'search', :action => 'search', :as => 'search'
      end
    end
  end

  namespace :inventory do
    resources :suppliers, only: [:index, :new, :create, :show] do
      resources :products, only: [] do
        resources :variants, only: [] do
          resources :adjustments, only: [:new, :create, :index]
        end
      end
    end
  end
  resources :inventories, only: [:index]
end
