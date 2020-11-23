Rails.application.routes.draw do
  namespace :v1 do
    resources :accounts, only: [:show, :create]
    resources :transfers, only: [:create]
  end
end
