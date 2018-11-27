Rails.application.routes.draw do
  resources :products do
    resources :purchases do
    end
  end
  # get 'products/index'
  devise_for :users
  # root to: 'pages#home'
  root to: 'products#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'purchases/pay_request'

end
