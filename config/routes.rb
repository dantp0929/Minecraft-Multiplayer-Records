# frozen_string_literal: true

Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root 'track#index'

  resources :track

  post '/track/convert', to: 'track#convert'
  post '/track/download', to: 'track#download'
  post '/track/destroy_many', to: 'track#destroy_many'
end
