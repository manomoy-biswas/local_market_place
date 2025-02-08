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

      resources :experiences do
        member do
          get :check_availability
        end
        collection do
          get :host_experiences
        end
        resources :bookings do
          member do
            post :cancel
          end
        end
        resources :reviews
      end

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

      resources :payments do
        member do
          post :refund
        end
      end
    end
  end
end
