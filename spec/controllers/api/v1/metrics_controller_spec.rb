require 'rails_helper'

RSpec.describe Api::V1::MetricsController, type: :controller do
  describe 'GET #show' do
    subject { get :show, params }
    let(:base_params) { { id: metric } }
    let(:params) { base_params }

    context 'unknown' do
      let(:metric) { :unknown }

      specify do
        subject
        expect(response).to have_http_status(:not_found)
      end

      specify do
        subject
        expect(json_response).to eq('error' => 'Metric "unknown" not found')
      end
    end

    context 'messages_sent' do
      let(:metric) { :messages_sent }

      specify do
        expect(Metric).to receive(:find).with('messages_sent').and_call_original
        subject
      end

      specify do
        expect(Metric::MessagesSent).to receive(:new).with(group_by: :day).and_call_original
        subject
      end

      context 'group_by :week' do
        let(:params) { base_params.merge(group_by: :week) }

        specify do
          expect(Metric::MessagesSent).to receive(:new).with(group_by: :week).and_call_original
          subject
        end
      end

      context 'group_by :foo' do
        let(:params) { base_params.merge(group_by: :foo) }

        specify do
          subject
          expect(json_response).to eq('error' => "invalid group_by value: :foo, valid fields are #{Groupdate::FIELDS}")
        end

        specify do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'GET #index' do
    subject { get :index }

    specify do
      subject
      expect(response).to have_http_status(:ok)
    end

    specify do
      subject
      expect(json_response).to eq(['active_users', 'messages_sent'])
    end
  end
end
