require 'rails_helper'

RSpec.describe Metric::MessagesCountBetweenUsers, type: :model do
  let(:instance) { described_class.new(attributes) }

  let(:user)     { gen_hash }
  let(:friend_1) { gen_hash }
  let(:friend_2) { gen_hash }

  let(:video_121) { video_data(user, friend_1, gen_video_id) }
  let(:video_122) { video_data(user, friend_1, gen_video_id) }
  let(:video_123) { video_data(user, friend_1, gen_video_id) }
  let(:video_124) { video_data(user, friend_1, gen_video_id) }

  let(:video_131) { video_data(user, friend_2, gen_video_id) }
  let(:video_132) { video_data(user, friend_2, gen_video_id) }
  let(:video_133) { video_data(user, friend_2, gen_video_id) }
  let(:video_134) { video_data(user, friend_2, gen_video_id) }

  let(:video_211) { video_data(friend_1, user, gen_video_id) }
  let(:video_212) { video_data(friend_1, user, gen_video_id) }

  let(:video_311) { video_data(friend_2, user, gen_video_id) }
  let(:video_312) { video_data(friend_2, user, gen_video_id) }

  describe '#user_id' do
    subject { instance.user_id }

    context 'RxDrzAIuF9mFw7Xx9NSM' do
      let(:attributes) { { user_id: 'RxDrzAIuF9mFw7Xx9NSM' } }
      it { is_expected.to eq('RxDrzAIuF9mFw7Xx9NSM') }
    end
  end

  describe '#friends_ids' do
    subject { instance.friends_ids }

    context '[fxVPRkGICwnrAwym52gK, RxDrzAIuF9mFw7Xx9NSM]' do
      let(:attributes) { { friends_ids: %w(fxVPRkGICwnrAwym52gK RxDrzAIuF9mFw7Xx9NSM) } }
      it { is_expected.to eq(['fxVPRkGICwnrAwym52gK', 'RxDrzAIuF9mFw7Xx9NSM']) }
    end
  end

  describe '#generate' do
    subject { instance.generate }

    before do
      # 1 -> 2
      video_flow video_121
      video_flow video_122
      video_flow video_123
      video_flow video_124

      # 1 -> 3
      video_flow video_131
      video_flow video_132
      video_flow video_133
      video_flow video_134

      # 2 -> 1
      video_flow video_211
      video_flow video_212

      # 3 -> 1
      video_flow video_311
      video_flow video_312
    end

    let(:attributes) { { user_id: user, friends_ids: [friend_1, friend_2] } }

    specify do
      result = [
        { 'sender' => friend_2, 'receiver' => user, 'count' => 2 },
        { 'sender' => friend_1, 'receiver' => user, 'count' => 2 },
        { 'sender' => user, 'receiver' => friend_2, 'count' => 4 },
        { 'sender' => user, 'receiver' => friend_1, 'count' => 4 }
      ]
      is_expected.to include(*result)
    end
  end
end
