Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :events, only: [:index, :create, :show]
      resources :status, only: [:index] do
        get :heartbeat, on: :collection
      end
      resources :metrics, only: [:index] do
        post ':id' => :show, on: :collection
        get 'filter/:id' => :show, prefix: 'filter', on: :collection
      end
      resources :messages, only: [:index, :show] do
        get :events, on: :member
      end
    end
  end

  get 'heartbeat' => 'api/v1/status#heartbeat'
end
