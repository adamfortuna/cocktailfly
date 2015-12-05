Rails.application.routes.draw do

  root 'home#index'

  resources :cocktails
  resources :ingredients

  resources :users do
    resources :ingredients, controller: 'user_ingredients'
  end
end
