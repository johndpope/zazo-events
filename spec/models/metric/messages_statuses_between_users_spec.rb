require 'rails_helper'

RSpec.describe Metric::MessagesStatusesBetweenUsers, type: :model do
  let(:factor) { 1 }
  let(:user_id) { gen_hash }
  let(:friend_1) { gen_hash }
  let(:friend_2) { gen_hash }
  let(:friend_3) { gen_hash }
  let(:instance) { described_class.new(user_id: user_id, friend_ids: [friend_1, friend_2, friend_3]) }

  describe '#generate' do
    subject { instance.generate }

    before do
      Timecop.scale(3600) do
        factor.times do
          video_o11 = video_data(user_id, friend_1, gen_video_id)
          video_o12 = video_data(user_id, friend_1, gen_video_id)
          video_o13 = video_data(user_id, friend_1, gen_video_id)
          video_o14 = video_data(user_id, friend_1, gen_video_id)

          video_i11 = video_data(friend_1, user_id, gen_video_id)
          video_i12 = video_data(friend_1, user_id, gen_video_id)
          video_i13 = video_data(friend_1, user_id, gen_video_id)
          video_i14 = video_data(friend_1, user_id, gen_video_id)
          video_i15 = video_data(friend_1, user_id, gen_video_id)

          video_o21 = video_data(user_id, friend_2, gen_video_id)
          video_o22 = video_data(user_id, friend_2, gen_video_id)
          video_o23 = video_data(user_id, friend_2, gen_video_id)
          video_o24 = video_data(user_id, friend_2, gen_video_id)
          video_o25 = video_data(user_id, friend_2, gen_video_id)

          video_i21 = video_data(friend_2, user_id, gen_video_id)
          video_i22 = video_data(friend_2, user_id, gen_video_id)
          video_i23 = video_data(friend_2, user_id, gen_video_id)
          video_i24 = video_data(friend_2, user_id, gen_video_id)
          video_i25 = video_data(friend_2, user_id, gen_video_id)
          video_i26 = video_data(friend_2, user_id, gen_video_id)

          # user -> friend_1

          video_flow video_o11

          send_video video_o12
          receive_video video_o12
          download_video video_o12

          send_video video_o13
          receive_video video_o13

          send_video video_o14
          receive_video video_o14
          download_video video_o14
          kvstore_view_video video_o14

          # friend_1 -> user

          video_flow video_i11

          send_video video_i12
          receive_video video_i12
          download_video video_i12

          send_video video_i13
          receive_video video_i13
          download_video video_i13

          send_video video_i14
          receive_video video_i14
          download_video video_i14
          kvstore_view_video video_i14

          send_video video_i15
          receive_video video_i15
          download_video video_i15
          notification_view_video video_i15

          # user -> friend_2

          video_flow video_o21

          send_video video_o22
          receive_video video_o22
          download_video video_o22

          send_video video_o23
          receive_video video_o23

          send_video video_o24
          receive_video video_o24

          send_video video_o25
          receive_video video_o25
          download_video video_o25
          kvstore_view_video video_o25

          # friend_2 -> user

          video_flow video_i21

          send_video video_i22
          receive_video video_i22
          download_video video_i22

          send_video video_i23
          receive_video video_i23
          download_video video_i23

          send_video video_i24
          receive_video video_i24
          download_video video_i24
          kvstore_view_video video_i24

          send_video video_i25
          receive_video video_i25
          download_video video_i25
          kvstore_view_video video_i25

          send_video video_i26
          receive_video video_i26
          download_video video_i26
          notification_view_video video_i26
        end
      end
    end

    specify do
      Benchmark.measure do
        is_expected.to eq(
          friend_1 => {
            outgoing: {
              sent: 4 * factor,
              incomplete: 3 * factor,
              unviewed: 2 * factor
            },
            incoming: {
              sent: 5 * factor,
              incomplete: 4 * factor,
              unviewed: 2 * factor
            } },
          friend_2 => {
            outgoing: {
              sent: 5 * factor,
              incomplete: 4 * factor,
              unviewed: 3 * factor
            },
            incoming: {
              sent: 6 * factor,
              incomplete: 5 * factor,
              unviewed: 2 * factor
            } },
          friend_3 => {
            outgoing: {
              sent: 0,
              incomplete: 0,
              unviewed: 0
            },
            incoming: {
              sent: 0,
              incomplete: 0,
              unviewed: 0
            } },
          total:  {
            outgoing: {
              sent: 9 * factor,
              incomplete: 7 * factor,
              unviewed: 5 * factor
            },
            incoming: {
              sent: 11 * factor,
              incomplete: 9 * factor,
              unviewed: 4 * factor
            } })
      end
    end
  end
end
