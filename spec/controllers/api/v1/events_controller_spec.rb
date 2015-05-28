require 'rails_helper'

RSpec.describe Api::V1::EventsController, type: :controller, event_builders: true do
  let(:message_id) { Digest::UUID.uuid_v4 }
  let(:s3_event) { json_fixture('s3_event') }
  let(:attributes) do
    { name: %w(video s3 uploaded),
      triggered_by: 'aws:s3',
      triggered_at: '2015-04-22T18:01:20.663Z',
      initiator: 's3',
      initiator_id: nil,
      target: 'video',
      target_id: 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998',
      data: { 'sender_id' => 'RxDrzAIuF9mFw7Xx9NSM',
              'receiver_id' => '6pqpuUZFp1zCXLykfTIx',
              'video_filename' => 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998' } }
  end

  describe 'GET #index' do
    let!(:event1) { create(:event, triggered_at: 1.minute.ago) }
    let!(:event2) { create(:event) }

    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    context 'when event exists' do
      it 'returns array of events' do
        get :index
        expect(json_response).to eq(JSON.parse([event1, event2].to_json))
      end
    end

    context 'filter_by is set' do
      let(:user_id) { gen_hash }
      subject { get :index, filter_by: user_id }

      specify do
        expect(Event).to receive(:filter_by).with(user_id)
        subject
      end
    end

    context 'pagination' do
      context 'for second page' do
        subject { get :index, page: 2 }
        specify do
          expect(Event).to receive(:page).with('2')
          subject
        end

        it 'returns empty array' do
          subject
          expect(json_response).to eq([])
        end
      end
    end

    context 'reverse' do
      subject { get :index, reverse: true }

      it 'returns array of events' do
        subject
        expect(json_response).to eq(JSON.parse([event2, event1].to_json))
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
      let(:params) { { name: %w(zazo test) } }

      it 'returns http ok' do
        post :create, params
        expect(response).to have_http_status(:ok)
      end

      specify do
        expect do
          post :create, params
        end.to_not change { Event.count }
      end

      context 'when name is string' do
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
    end

    context 'generic event' do
      let(:params) do
        { name: %w(video notification received),
          triggered_at: DateTime.now.utc.to_json,
          triggered_by: 'zazo:api',
          initiator: 'admin',
          initiator_id: nil,
          target: 'video',
          target_id: 'IUed5vP9n4qzW6jY8wSu-smRug5xj8J469qX5XvGk-220943fef3c03f4aa415beaf9f05c9c2',
          data: { 'sender_id' => 'IUed5vP9n4qzW6jY8wSu', 'receiver_id' => 'smRug5xj8J469qX5XvGk', 'video_filename' => 'IUed5vP9n4qzW6jY8wSu-smRug5xj8J469qX5XvGk-220943fef3c03f4aa415beaf9f05c9c2', 'video_id' => '1430762196568' },
          raw_params: { 'sender_id' => 'IUed5vP9n4qzW6jY8wSu', 'id' => '1' } }
      end

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
        expect(Event.last).to have_attributes(params)
      end

      context 'with X-Aws-Sqsd-Msgid header' do
        before { request.headers['X-Aws-Sqsd-Msgid'] = message_id }

        it 'creates event with valid attributes' do
          post :create, params
          expect(Event.last).to have_attributes(params.merge(message_id: message_id))
        end
      end

      context 'when name is string' do
        it 'creates event with valid attributes' do
          post :create, params.merge(name: 'video:notification:received')
          expect(Event.last).to have_attributes(params)
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
        expect(json_response).to eq(JSON.parse(event.to_json))
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
