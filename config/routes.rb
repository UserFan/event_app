Rails.application.routes.draw do

  devise_for :users

  root  'static_pages#home'

  resource :calendar, only: :show do
    get 'all'
  end

  resources :events do
    get 'all', on: :collection
  end


  get '/about', to: 'static_pages#about'
  get '/events',  to: 'events#new'
  get 'persons/profile', as: 'user_root'
end
