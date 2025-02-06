Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :experiences do
        resources :bookings
        resources :reviews
      end

      resources :users do
        resources :messages
      end

      resources :payments
    end
  end
end
