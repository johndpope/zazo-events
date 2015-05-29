require 'rails_helper'

RSpec.describe Metric::AggregateMessagingInfo, type: :model do
  let(:instance) { described_class.new(attributes) }
  let(:user_1) { gen_hash }
  let(:user_2) { gen_hash }
  let(:user_3) { gen_hash }

  let(:video_121) { video_data(user_1, user_2, gen_video_id) }
  let(:video_122) { video_data(user_1, user_2, gen_video_id) }
  let(:video_123) { video_data(user_1, user_2, gen_video_id) }
  let(:video_124) { video_data(user_1, user_2, gen_video_id) }

  let(:video_211) { video_data(user_2, user_1, gen_video_id) }
  let(:video_212) { video_data(user_2, user_1, gen_video_id) }
  let(:video_213) { video_data(user_2, user_1, gen_video_id) }
  let(:video_214) { video_data(user_2, user_1, gen_video_id) }
  let(:video_215) { video_data(user_2, user_1, gen_video_id) }

  let(:video_131) { video_data(user_1, user_3, gen_video_id) }
  let(:video_132) { video_data(user_1, user_3, gen_video_id) }
  let(:video_133) { video_data(user_1, user_3, gen_video_id) }
  let(:video_134) { video_data(user_1, user_3, gen_video_id) }

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

  describe '#friend_id' do
    subject { instance.friend_id }

    context 'RxDrzAIuF9mFw7Xx9NSM' do
      let(:attributes) { { user_id: 'RxDrzAIuF9mFw7Xx9NSM', friend_id: 'fxVPRkGICwnrAwym52gK' } }
      it { is_expected.to eq('fxVPRkGICwnrAwym52gK') }
    end
  end

  describe '#generate' do
    subject { instance.generate }

    before do
      # 1 -> 2
      video_flow video_121

      send_video video_122
      receive_video video_122

      send_video video_123
      receive_video video_123
      download_video video_123

      send_video video_124

      # 2 -> 1
      video_flow video_211
      video_flow video_212

      send_video video_213
      receive_video video_213

      send_video video_214
      receive_video video_214
      download_video video_214

      send_video video_215

      # 1 -> 3
      video_flow video_131

      send_video video_132
      receive_video video_132

      send_video video_133
      receive_video video_133
      download_video video_133

      send_video video_134
    end

    context 'only for user' do
      context 'for user_1' do
        let(:attributes) { { user_id: user_1 } }

        specify do
          is_expected.to eq(
            outgoing: {
              total_sent: 8, total_received: 4, undelivered_percent: 50.0
            },
            incoming: {
              total_sent: 5, total_received: 3, undelivered_percent: 200.0 / 5
            })
        end
      end

      context 'for user_2' do
        let(:attributes) { { user_id: user_2 } }

        specify do
          is_expected.to eq(
            outgoing: {
              total_sent: 5, total_received: 3, undelivered_percent: 200.0 / 5
            },
            incoming: {
              total_sent: 4, total_received: 2, undelivered_percent: 100.0 / 2
            })
        end
      end
    end

    context 'from user_1 to user_2' do
      let(:attributes) { { user_id: user_1, friend_id: user_2 } }

      specify do
        is_expected.to eq(
          outgoing: {
            total_sent: 4, total_received: 2, undelivered_percent: 50.0
          },
          incoming: {
            total_sent: 5, total_received: 3, undelivered_percent: 200.0 / 5
          })
      end
    end
  end
end
