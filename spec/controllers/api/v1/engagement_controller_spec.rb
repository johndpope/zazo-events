require 'rails_helper'

RSpec.describe Api::V1::EngagementController, type: :controller do
  describe 'GET #messages_sent' do
    let(:params) { {} }
    subject { get :messages_sent, params }

    context 'empty group_by' do
      specify do
        expect(Metric::MessagesSent).to receive(:new).with(group_by: :day).and_call_original
        subject
      end
    end

    context 'group_by :week' do
      let(:params) { { group_by: :week } }

      specify do
        expect(Metric::MessagesSent).to receive(:new).with(group_by: :week).and_call_original
        subject
      end
    end

    context 'group_by :foo' do
      let(:params) { { group_by: :foo } }

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
