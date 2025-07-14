Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # for home_controller
  root 'home#home_page' 
  get 'page_unaccessible', to: 'home#page_unaccessible'

  # for reset_password controller
  resources :reset_password, only: [:new, :create, :edit, :update] do
    collection do
      get :verify_reset_code_page
      post :verify_reset_code
    end
  end

  #for create_accounts controller
  resources :accounts, controller: 'create_account', only: [:new, :create, :index] do
    collection do
      get  :verify_code_page
      post :verify_code
      post :resend_verification_email
    end
  end

  resources :login_account, only: [:new, :create, :index] do
    collection do
      get :log_out
      get :profile
      get :admin_view
    end
  end

  

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
