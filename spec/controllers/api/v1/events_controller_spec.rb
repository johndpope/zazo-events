require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller do
  let(:message_id) { Digest::UUID.uuid_v4 }
  let(:s3_event) { json_fixture('s3_event') }
  let(:attributes) do
    { name: 'video:s3:uploaded',
      triggered_by: 'aws:s3',
      triggered_at: '2015-04-22T18:01:20.663Z',
      initiator: 'user',
      initiator_id: 'RxDrzAIuF9mFw7Xx9NSM',
      target: 'video',
      target_id: 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998',
      data: { 'sender_id' => 'RxDrzAIuF9mFw7Xx9NSM',
              'receiver_id' => '6pqpuUZFp1zCXLykfTIx',
              'video_filename' => 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998' } }
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    context 'when event exists' do
      let!(:event) { create(:event) }
      it 'returns array of events' do
        get :index
        expect(JSON.parse(response.body)).to eq([JSON.parse(event.to_json)])
      end
    end
  end

  describe 'POST #create' do
    context 'S3 event' do
      let(:params) { s3_event }

      it 'returns http ok' do
        post :create, params
        expect(response).to have_http_status(:ok)
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

      context 'with X-Aws-Sqsd-Msgid header' do
        before { request.headers['X-Aws-Sqsd-Msgid'] = message_id }

        it 'creates event with valid attributes' do
          post :create, params
          expect(Event.last).to have_attributes(attributes.merge(message_id: message_id))
        end
      end
    end

    context 'S3 test event' do
      let(:params) { json_fixture('s3_test_event') }

      it 'returns http ok' do
        post :create, params
        expect(response).to have_http_status(:ok)
      end

      specify do
        expect do
          post :create, params
        end.to_not change { Event.count }
      end
    end

    context 'generic test event' do
      let(:params) { { name: 'test' } }

      it 'returns http ok' do
        post :create, params
        expect(response).to have_http_status(:ok)
      end

      specify do
        expect do
          post :create, params
        end.to_not change { Event.count }
      end
    end

    context 'generic event' do
      let(:params) { attributes }

      it 'returns http ok' do
        post :create, params
        expect(response).to have_http_status(:ok)
      end

      specify do
        expect do
          post :create, params
        end.to change { Event.count }.by(1)
      end

      it 'creates event with valid attributes' do
        post :create, params
        expect(Event.last).to have_attributes(
          name: 'video:s3:uploaded',
          triggered_by: 'aws:s3',
          triggered_at: '2015-04-22T18:01:20.663Z'.to_datetime,
          initiator: 'user',
          initiator_id: 'RxDrzAIuF9mFw7Xx9NSM',
          target: 'video',
          target_id: 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998',
          data: { 'sender_id' => 'RxDrzAIuF9mFw7Xx9NSM',
                  'receiver_id' => '6pqpuUZFp1zCXLykfTIx',
                  'video_filename' => 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998' },
          raw_params: nil)
      end

      context 'with X-Aws-Sqsd-Msgid header' do
        before { request.headers['X-Aws-Sqsd-Msgid'] = message_id }

        it 'creates event with valid attributes' do
          post :create, params
          expect(Event.last).to have_attributes(
            name: 'video:s3:uploaded',
            triggered_by: 'aws:s3',
            triggered_at: '2015-04-22T18:01:20.663Z'.to_datetime,
            initiator: 'user',
            initiator_id: 'RxDrzAIuF9mFw7Xx9NSM',
            target: 'video',
            target_id: 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998',
            data: { 'sender_id' => 'RxDrzAIuF9mFw7Xx9NSM',
                    'receiver_id' => '6pqpuUZFp1zCXLykfTIx',
                    'video_filename' => 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998' },
            raw_params: nil,
            message_id: message_id)
        end
      end
    end

    context 'with invalid params' do
      let(:params) { { name: 'bad_event' } }

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
