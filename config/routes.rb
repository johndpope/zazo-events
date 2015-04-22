Rails.application.routes.draw do
  get 'heartbeat' => 'events#heartbeat'
  resources :events, only: [:index, :create]
end
