require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do
  let(:s3_event) { json_fixture('s3_event')['Records'] }
  let!(:event) { Event.create_from_s3_event(s3_event).first }
  let(:instance) { Message.new(event) }
  let(:sender_id) { event.data['sender_id'] }
  let(:receiver_id) { event.data['receiver_id'] }
  let(:filename) { event.data['video_filename'] }

  describe 'GET #index' do
    subject { get :index }

    context 'without sender_id and receiver_id' do
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      specify do
        expect(Message).to receive(:all_events).and_call_original
        subject
      end

      specify do
        subject
        expect(json_response).to include(JSON.parse(instance.to_json))
      end
    end

    context 'with sender_id and receiver_id' do
      subject { get :index, sender_id: sender_id, receiver_id: receiver_id }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      specify do
        expect(Message).to receive(:by_direction_events).with(sender_id, receiver_id).and_call_original
        subject
      end

      specify do
        subject
        expect(json_response).to include(JSON.parse(instance.to_json))
      end
    end
  end
end
