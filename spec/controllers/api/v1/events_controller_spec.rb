require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller do
  let(:s3_event) { json_fixture('event') }
  let(:attributes) do
    { name: 'video:sent',
      triggered_by: 'aws:s3',
      triggered_at: '2015-04-22T18:01:20.663Z'.to_datetime,
      initiator: 'user',
      initiator_id: 'RxDrzAIuF9mFw7Xx9NSM',
      target: 'user',
      target_id: '6pqpuUZFp1zCXLykfTIx' }
  end
  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'returns array of events' do
      event = create(attributes)
      get :index
      expect(JSON.parse(response.body)).to eq([event.attributes])
    end
  end

  describe 'POST #create' do
    context 'S3 event' do
      let(:params) { s3_event }

      it 'returns http created' do
        post :create, params
        expect(response).to have_http_status(:created)
      end

      specify do
        expect do
          post :create, params
        end.to change { Event.count }.by(1)
      end

      it 'creates event with valid attributes' do
        post :create, params
        expect(Event.last).to have_attributes(attributes)
      end
    end

    context 'simple event' do
      let(:params) { { event: attributes } }

      it 'returns http created' do
        post :create, params
        expect(response).to have_http_status(:created)
      end

      specify do
        expect do
          post :create, params
        end.to change { Event.count }.by(1)
      end

      it 'creates event with valid attributes' do
        post :create, params
        expect(Event.last).to have_attributes(attributes)
      end
    end

    context 'with invalid params' do
      let(:params) { { event: 'foo' } }

      it 'returns http unprocessable_entity' do
        post :create, params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'GET #show' do
    context 'event exists' do
      let!(:event) { create(:event) }
      let(:params) { { id: event.to_param } }

      it 'returns http success' do
        get :show, params
        expect(response).to have_http_status(:success)
      end

      it 'renders event' do
        get :show, params
        expect(JSON.parse(response.body)).to eq(JSON.parse(event.to_json))
      end
    end

    context 'event not exists' do
      let(:params) { { id: 111_111_111 } }

      it 'returns http not_found' do
        get :show, params
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
