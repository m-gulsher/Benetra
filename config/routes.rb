Rails.application.routes.draw do
  resources :policies
  resources :companies
  resources :agencies
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  root "home#index"
end
