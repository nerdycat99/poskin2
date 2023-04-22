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

  resources :orders, only: [:create, :edit, :update, :show, :destroy] do
    resources :receipts, only: [:create, :show]#, defaults: { format: :pdf }
    resources :payments, only: [:new, :create]
    resources :items, only: [:new, :create, :destroy]
  end
  resources :catalogue, only: [:index]
  resources :suppliers, only: [:index, :new, :create, :show, :edit, :update]

  namespace :catalogue do
    resources :suppliers, only: [:index, :new, :create, :show] do
      resources :products, only: [:index, :new, :create, :edit, :update, :destroy, :show] do
        resources :variants, only: [:new, :create, :edit, :update, :destroy, :show]
        resources :product_attributes, only: [:new, :create]
        resources :product_attribute_types, only: [:index, :new, :create, :destroy]
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
