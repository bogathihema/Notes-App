Rails.application.routes.draw do
  root "notes#index"

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'welcome', to: 'sessions#welcome'
  get 'logout', to: "sessions#logout"
  get 'sessions/login'
  get 'users/create'

  resources :users  do
    resources :notes do
      get :share_note, on: :collection
      post :save_sharing
      get :edit_permissions
      get :change_permissions, on: :collection
      post :update_permissions
      resources :tags do
        get :add_tag, on: :collection
      end

    end
  end


  # resources :notes do
  # end
  #
  # resources :tags do
  # end




  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
