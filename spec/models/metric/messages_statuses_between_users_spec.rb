require 'rails_helper'

RSpec.describe Metric::MessagesStatusesBetweenUsers, type: :model do
  let(:user_id) { gen_hash }
  let(:friend_id) { gen_hash }
  let(:instance) { described_class.new(user_id: user_id, friend_id: friend_id) }

  let(:video_121) { video_data(user_id, friend_id, gen_video_id) }
  let(:video_122) { video_data(user_id, friend_id, gen_video_id) }
  let(:video_123) { video_data(user_id, friend_id, gen_video_id) }
  let(:video_124) { video_data(user_id, friend_id, gen_video_id) }

  let(:video_211) { video_data(friend_id, user_id, gen_video_id) }
  let(:video_212) { video_data(friend_id, user_id, gen_video_id) }
  let(:video_213) { video_data(friend_id, user_id, gen_video_id) }
  let(:video_214) { video_data(friend_id, user_id, gen_video_id) }
  let(:video_215) { video_data(friend_id, user_id, gen_video_id) }

  describe '#generate' do
    subject { instance.generate }

    before do
      # user -> friend

      video_flow video_121

      send_video video_122
      receive_video video_122
      download_video video_122

      send_video video_123
      receive_video video_123

      send_video video_124
      receive_video video_124
      download_video video_124
      kvstore_view_video video_124

      # friend -> user

      video_flow video_211

      send_video video_212
      receive_video video_212
      download_video video_212

      send_video video_213
      receive_video video_213
      download_video video_213

      send_video video_214
      receive_video video_214
      download_video video_214
      kvstore_view_video video_214

      send_video video_215
      receive_video video_215
      download_video video_215
      notification_view_video video_215
    end

    specify do
      is_expected.to eq(
        outgoing: {
          sent: 4,
          incomplete: 3,
          unviewed: 2
        },
        incoming: {
          sent: 5,
          incomplete: 4,
          unviewed: 2
        })
    end
  end
end
