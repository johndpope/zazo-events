require 'rails_helper'

RSpec.describe Api::V1::EngagementController, type: :controller do
  describe 'GET #messages_sent' do
    before do
      create(:event, triggered_at: '2015-05-10 00:01:00 UTC')
      create(:event, triggered_at: '2015-05-10 00:02:00 UTC')
      create(:event, triggered_at: '2015-05-10 00:03:00 UTC')
      create(:event, triggered_at: '2015-05-11 00:01:00 UTC')
      create(:event, triggered_at: '2015-05-11 00:02:00 UTC')
      create(:event, triggered_at: '2015-05-12 00:03:00 UTC')
    end

    it 'returns count groupped by day' do
      get :messages_sent
      expect(json_response).to eq('2015-05-10 00:00:00 UTC' => 3,
                                  '2015-05-11 00:00:00 UTC' => 2,
                                  '2015-05-12 00:00:00 UTC' => 1)
    end
  end
end
