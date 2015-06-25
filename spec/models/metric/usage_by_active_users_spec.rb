require 'rails_helper'

RSpec.describe Metric::UsageByActiveUsers, type: :model do
  describe '#generate' do
    let(:instance) { described_class.new(group_by: group_by) }
    subject { instance.generate }

    context 'by day' do
      let(:group_by) { :day }
      let(:user_1) { gen_hash }
      let(:user_2) { gen_hash }
      let(:user_3) { gen_hash }
      let(:user_4) { gen_hash }
      let(:video_1) { gen_video_id }
      let(:video_2) { gen_video_id }
      let(:video_3) { gen_video_id }
      let(:video_4) { gen_video_id }
      let(:video_5) { gen_video_id }

      before do
        Timecop.travel(3.days.ago) do
          video_flow(video_data(user_1, user_2, video_1))
          video_flow(video_data(user_1, user_2, video_2))
          video_flow(video_data(user_2, user_3, video_3))
          video_flow(video_data(user_2, user_3, video_3))
        end
        Timecop.travel(2.days.ago) do
          video_flow(video_data(user_1, user_2, video_1))
          video_flow(video_data(user_2, user_3, video_2))
          video_flow(video_data(user_2, user_3, video_4))
          video_flow(video_data(user_2, user_3, video_4))
          video_flow(video_data(user_3, user_4, video_3))
        end
        Timecop.travel(1.days.ago) do
          video_flow(video_data(user_1, user_2, video_1))
          video_flow(video_data(user_2, user_3, video_2))
          video_flow(video_data(user_2, user_3, video_3))
          video_flow(video_data(user_3, user_4, video_4))
          video_flow(video_data(user_3, user_4, video_5))
          video_flow(video_data(user_3, user_4, video_5))
        end
      end

      specify do
        is_expected.to eq(
          3.days.ago.midnight => 3.0 / 2.0,
          2.days.ago.midnight => 4.0 / 3.0,
          1.days.ago.midnight => 5.0 / 3.0)
      end
    end
  end
end
