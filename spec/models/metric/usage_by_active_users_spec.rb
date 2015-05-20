require 'rails_helper'

RSpec.describe Metric::UsageByActiveUsers, type: :model do
  include EventBuilders

  describe '#generate' do
    let(:instance) { described_class.new(group_by: group_by) }
    subject { instance.generate }

    context 'by day' do
      let(:group_by) { :day }
      let(:user_1) { gen_user_id }
      let(:user_2) { gen_user_id }
      let(:user_3) { gen_user_id }
      let(:user_4) { gen_user_id }
      let(:video_1) { gen_video_id }
      let(:video_2) { gen_video_id }
      let(:video_3) { gen_video_id }
      let(:video_4) { gen_video_id }

      before do
        Timecop.travel(3.days.ago) do
          send_video(event_data(user_1, user_2, video_1))
          send_video(event_data(user_2, user_3, video_2))
          receiver_video_flow(event_data(user_1, user_2, video_1))
          receiver_video_flow(event_data(user_2, user_3, video_2))
        end
        Timecop.travel(2.days.ago) do
          send_video(event_data(user_1, user_2, video_1))
          send_video(event_data(user_2, user_3, video_2))
          send_video(event_data(user_3, user_4, video_3))
          receiver_video_flow(event_data(user_1, user_2, video_1))
          receiver_video_flow(event_data(user_2, user_3, video_2))
        end
        Timecop.travel(1.days.ago) do
          send_video(event_data(user_1, user_2, video_1))
          send_video(event_data(user_2, user_3, video_2))
          send_video(event_data(user_3, user_4, video_3))
          receiver_video_flow(event_data(user_1, user_2, video_1))
          receiver_video_flow(event_data(user_2, user_3, video_2))
          receiver_video_flow(event_data(user_3, user_4, video_2))
        end
      end

      specify do
        is_expected.to eq(
          3.days.ago.midnight => 1.0,
          2.days.ago.midnight => 1.0,
          1.days.ago.midnight => 1.0)
      end
    end
  end
end
