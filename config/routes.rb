Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :events, only: [:index, :create, :show]
      resources :status, only: [:index] do
        get :heartbeat, on: :collection
      end
    end
  end

  get 'heartbeat' => 'api/v1/status#heartbeat'
end
