require 'rails_helper'

RSpec.describe Api::V1::MetricsController, type: :controller do
  describe 'GET #show' do
    subject { get :show, params }
    let(:base_params) { { 'id' => metric } }
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
        expect(Metric::MessagesSent).to receive(:new).with({}).and_call_original
        subject
      end

      context 'group_by :week' do
        let(:params) { base_params.merge('group_by' => 'week') }

        specify do
          expect(Metric::MessagesSent).to receive(:new).with('group_by' => 'week').and_call_original
          subject
        end
      end

      context 'group_by :foo' do
        let(:params) { base_params.merge('group_by' => 'foo') }

        specify do
          subject
          expect(json_response).to eq('errors' => { 'group_by' => ["is not included in #{Groupdate::FIELDS}"] })
        end

        specify do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'user_activity' do
      let(:metric) { :user_activity }
      let(:params) { base_params.merge('user_id' => 'RxDrzAIuF9mFw7Xx9NSM') }

      specify do
        expect(Metric).to receive(:find).with('user_activity').and_call_original
        subject
      end

      specify do
        expect(Metric::UserActivity).to receive(:new).with('user_id' => 'RxDrzAIuF9mFw7Xx9NSM').and_call_original
        subject
      end

      context 'user_id not set' do
        let(:params) { base_params }

        specify do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        specify do
          subject
          expect(json_response).to eq('errors' => { 'user_id' => ["can't be blank"] })
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
      expect(json_response.first).to eq('name' => 'active_users',
                                        'type' => 'aggregated_by_timeframe')
    end

    context 'response' do
      specify do
        subject
        expect(json_response).to be_a(Array)
      end

      context 'size' do
        specify do
          subject
          expect(json_response.size).to be > 0
        end
      end
    end
  end
end
