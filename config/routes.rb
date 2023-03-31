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

  resources :sales, only: [:index]
  resources :catalogue, only: [:index]
  resources :suppliers, only: [:index, :new, :create, :show]

  namespace :catalogue do
    resources :suppliers, only: [:index, :new, :create, :show] do
      # collection do
      #   get :select
      #   post :selected
      # end
      resources :products, only: [:index, :new, :create] do
        resources :variants, only: [:new, :create]
        resources :product_attributes, only: [:new, :create]
      end
    end
  end
  resources :inventories, only: [:index]
end
