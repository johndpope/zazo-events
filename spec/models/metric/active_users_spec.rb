require 'rails_helper'

RSpec.describe Metric::ActiveUsers, type: :model do
  include EventBuilders

  let(:instance) { described_class.new(group_by: group_by) }

  describe '#generate' do
    subject { instance.generate }

    context 'by day' do
      let(:group_by) { :day }

      before do
        Timecop.travel(3.days.ago) do
          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(event_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(event_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(event_data(sender_id, receiver_id, video_id))
          download_video(event_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(event_data(sender_id, receiver_id, video_id))
          download_video(event_data(sender_id, receiver_id, video_id))
          view_video(event_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(2.days.ago) do
          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(event_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(event_data(sender_id, receiver_id, video_id))
          receive_video(event_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(event_data(sender_id, receiver_id, video_id))
          download_video(event_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(event_data(sender_id, receiver_id, video_id))
          download_video(event_data(sender_id, receiver_id, video_id))
          view_video(event_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(1.days.ago) do
          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(event_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(event_data(sender_id, receiver_id, video_id))
          receive_video(event_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(event_data(sender_id, receiver_id, video_id))
          download_video(event_data(sender_id, receiver_id, video_id))
          view_video(event_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(event_data(sender_id, receiver_id, video_id))
          download_video(event_data(sender_id, receiver_id, video_id))
          view_video(event_data(sender_id, receiver_id, video_id))
        end
      end

      specify do
        is_expected.to eq(3.days.ago.midnight => 2,
                          2.days.ago.midnight => 3,
                          1.days.ago.midnight => 4)
      end
    end
  end
end
