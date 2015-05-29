require 'rails_helper'

RSpec.describe Metric::UserActivity, type: :model do
  let(:instance) { described_class.new(attributes) }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
  end

  describe '#user_id' do
    subject { instance.user_id }

    context 'RxDrzAIuF9mFw7Xx9NSM' do
      let(:attributes) { { user_id: 'RxDrzAIuF9mFw7Xx9NSM' } }
      it { is_expected.to eq('RxDrzAIuF9mFw7Xx9NSM') }
    end
  end

  describe '#generate' do
    let(:attributes) { { user_id: user_id } }
    subject { instance.generate }

    context 'dataset 1' do
      let(:user_1) { gen_hash }
      let(:user_2) { gen_hash }
      let(:user_3) { gen_hash }
      let(:user_4) { gen_hash }
      let(:video_1) { gen_video_id }
      let(:video_2) { gen_video_id }

      before do
        @user_1_activity = []
        @user_2_activity = []
        e = build(:event, :user_initialized, initiator_id: user_1)
        e.initiator = 'user'
        e.save && @user_1_activity << e
        e = build(:event, :user_registered, initiator_id: user_1)
        e.initiator = 'user'
        e.save && @user_1_activity << e
        e = build(:event, :user_verified, initiator_id: user_1)
        e.initiator = 'user'
        e.save && @user_1_activity << e
        video_events_1 = video_flow video_data(user_1, user_2, video_1)
        @user_1_activity += video_events_1
        @user_2_activity += video_events_1
        e = build(:event, :user_initialized, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        e = build(:event, :user_invited, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        e = build(:event, :connection_established, initiator_id: "#{user_id}_#{user_2}")
        e.initiator = 'user'
        e.save
        invitation = build(:event, :user_invitation_sent, initiator_id: user_1,
                                                      target_id: user_2,
                                                      data: invitation_data(user_1, user_2))
        invitation.initiator = 'user'
        invitation.target = 'user'
        invitation.save
        @user_1_activity << invitation
        @user_2_activity << invitation
        e = build(:event, :user_registered, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        e = build(:event, :user_verified, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        video_events_2 = video_flow video_data(user_2, user_1, video_2)
        @user_1_activity += video_events_2
        @user_2_activity += video_events_2
      end

      context 'user_1' do
        let(:user_id) { user_1 }
        it { is_expected.to eq(@user_1_activity) }
      end

      context 'user_2' do
        let(:user_id) { user_2 }
        it { is_expected.to eq(@user_2_activity) }
      end
    end
  end
end
