Rails.application.routes.draw do

  resources :users, only: [:index, :show]
  get '', to: redirect('/login')
  get 'login', to: 'sessions#new', as: :login
  get '/auth/:provider/callback', to: 'sessions#create'
  resources :passages

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
