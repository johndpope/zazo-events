require 'rails_helper'

RSpec.describe Metric, type: :model do
  describe '.find' do
    subject { described_class.find(metric) }

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

  describe '.all' do
    subject { described_class.all }
    let(:all_metrics) do
      [Metric::ActiveUsers,
       Metric::AggregateMessagingInfo,
       Metric::Filter::NonMarketing,
       Metric::InvitationFunnel,
       Metric::InvitedBecomingRegistered,
       Metric::MessagesCountBetweenUsers,
       Metric::MessagesCountByPeriod,
       Metric::MessagesFailures,
       Metric::MessagesFailuresAutonotification,
       Metric::MessagesSent,
       Metric::MessagesStatusesBetweenUsers,
       Metric::NonMarketingRegisteredByWeeks,
       Metric::OnboardingInfo,
       Metric::UploadDuplications,
       Metric::UsageByActiveUsers,
       Metric::UserActivity,
       Metric::VerifiedAfterNthNotification]
    end
    it { is_expected.to eq(all_metrics) }
  end
end
