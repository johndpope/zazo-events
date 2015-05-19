require 'rails_helper'

RSpec.describe Metric, type: :model do
  describe '.build' do
    subject { described_class.build(metric) }

    context 'unknown' do
      let(:metric) { :unknown }
      specify do
        expect { subject }.to raise_error('Metric :unknown not found')
      end
    end

    context 'messages_sent' do
      let(:metric) { :messages_sent }
      it { is_expected.to eq(Metric::MessagesSent) }
    end

    context 'active_users' do
      let(:metric) { :active_users }
      it { is_expected.to eq(Metric::ActiveUsers) }
    end
  end
end
