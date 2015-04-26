require 'rails_helper'

RSpec.describe Api::V1::StatusController, type: :controller do
  describe 'GET #index' do
    before { get :index }
    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'returns app_name and version' do
      expect(JSON.parse(response.body)).to eq('app_name' => Settings.app_name,
                                              'version' => Settings.version)
    end
  end

  describe 'GET #heartbeat' do
    it 'returns http success' do
      get :heartbeat
      expect(response).to have_http_status(:success)
    end
  end
end
