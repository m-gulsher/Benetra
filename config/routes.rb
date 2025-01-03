Rails.application.routes.draw do
  resources :employees do
    collection do
      get :import
      post :import_csv
      get :import_progress
      get :import_results
    end
  end
  resources :agents
  resources :policies
  resources :companies
  resources :agencies
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  root "home#index"
end
