Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root "session#index"

  resources :session do
    member do
      post :download
    end
  end
end
