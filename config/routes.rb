Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post "auth/register", to: "auth#register"
      post "auth/login", to: "auth#login"
      get "auth/verify/:token", to: "auth#verify_email"
      post "auth/forgot_password", to: "auth#forgot_password"
      post "auth/reset_password", to: "auth#reset_password"
      post "auth/refresh", to: "auth#refresh_token"
      get "auth/:provider/callback", to: "auth#social_auth"
      delete "auth/logout", to: "auth#logout"

      resources :experiences do
        member do
          get :check_availability
        end
        collection do
          get :host_experiences
        end
      end
      resources :bookings do
        member do
          post :cancel
        end
        resources :payments do
          member do
            post :verify_payment
            get :checkout_options
          end
        end
      end
      resources :reviews

      resources :users do
        resources :messages do
          member do
            post :mark_as_read
          end
          collection do
            get "conversation/:user_id", to: "messages#conversation"
          end
        end
      end
      resources :hosts
    end
  end
end
