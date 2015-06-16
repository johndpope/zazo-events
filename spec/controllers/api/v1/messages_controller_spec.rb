require 'rails_helper'

RSpec.describe Api::V1::MessagesController, type: :controller do
  let(:s3_event) { json_fixture('s3_event')['Records'] }
  let!(:event) { Event.create_from_s3_event(s3_event).first }
  let(:instance) { Message.new(event) }
  let(:sender_id) { event.data['sender_id'] }
  let(:receiver_id) { event.data['receiver_id'] }
  let(:filename) { event.data['video_filename'] }

  describe 'GET #index' do
    let(:params) {}
    subject { get :index, params }

    let!(:message_1) { Message.new(send_video(video_data(sender_id, receiver_id, gen_video_id))) }
    let!(:message_2) { Message.new(send_video(video_data(sender_id, receiver_id, gen_video_id))) }

    context 'without sender_id and receiver_id' do
      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      specify do
        expect(Message).to receive(:all_events).with(nil).and_call_original
        subject
      end

      it 'returns list' do
        subject
        expect(json_response).to eq(JSON.parse([instance, message_1, message_2].to_json))
      end

      context 'reverse' do
        let(:params) { { reverse: true } }

        it 'returns list in reverse order' do
          subject
          expect(json_response).to eq(JSON.parse([message_2, message_1, instance].to_json))
        end
      end
    end

    context 'with sender_id and receiver_id' do
      let(:params) { { sender_id: sender_id, receiver_id: receiver_id } }

      it 'returns http success' do
        expect(response).to have_http_status(:success)
      end

      specify do
        expect(Message).to receive(:by_direction_events).with(sender_id, receiver_id, nil).and_call_original
        subject
      end

      it 'returns list' do
        subject
        expect(json_response).to eq(JSON.parse([instance, message_1, message_2].to_json))
      end

      context 'reverse' do
        let(:params) { { sender_id: sender_id, receiver_id: receiver_id, reverse: true } }

        it 'returns list in reverse order' do
          subject
          expect(json_response).to eq(JSON.parse([message_2, message_1, instance].to_json))
        end
      end
    end
  end

  describe 'GET #show' do
    subject { get :show, id: message_id }
    let(:message_id) { instance.id }

    context 'message not found' do
      let(:message_id) { 'unknown' }

      it 'returns http not found' do
        subject
        expect(response).to have_http_status(:not_found)
      end
    end

    specify do
      subject
      expect(json_response).to eq(JSON.parse(instance.to_json))
    end
  end

  describe 'GET #events' do
    subject { get :events, id: message_id }
    let(:message_id) { instance.id }

    context 'message not found' do
      let(:message_id) { 'unknown' }

      specify do
        subject
        expect(json_response).to eq([])
      end
    end

    specify do
      subject
      expect(json_response).to eq(JSON.parse(instance.events.to_json))
    end
  end
end
