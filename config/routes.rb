Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :events, only: [:index, :create, :show]
    end
  end

  get 'status',  to: Proc.new { [200, {}, ['']] }
  get 'version', to: Proc.new { [200, {}, ["#{Settings.app_name} #{Settings.version} (#{Rails.env})"]] }
end
