require 'rails_helper'

RSpec.describe Metric::MessagesSent, type: :model do
  let(:instance) { described_class.new(group_by: group_by) }

  let(:user_1) { gen_hash }
  let(:user_2) { gen_hash }

  let(:video_1) { gen_video_id }
  let(:video_2) { gen_video_id }
  let(:video_3) { gen_video_id }
  let(:video_4) { gen_video_id }
  let(:video_5) { gen_video_id }
  let(:video_6) { gen_video_id }
  let(:video_7) { gen_video_id }
  let(:video_8) { gen_video_id }

  describe '#generate' do
    subject { instance.generate }

    context 'by day' do
      let(:group_by) { :day }

      before do
        Timecop.travel(3.days.ago) do
          send_video video_data(user_1, user_2, video_1)
          send_video video_data(user_1, user_2, video_1)
          send_video video_data(user_1, user_2, video_2)
          send_video video_data(user_1, user_2, video_3)
        end
        Timecop.travel(2.days.ago) do
          send_video video_data(user_1, user_2, video_4)
          send_video video_data(user_1, user_2, video_4)
          send_video video_data(user_1, user_2, video_5)
          send_video video_data(user_1, user_2, video_5)
        end
        Timecop.travel(1.days.ago) do
          send_video video_data(user_1, user_2, video_6)
        end
      end

      specify do
        is_expected.to eq(3.days.ago.midnight => 3,
                          2.days.ago.midnight => 2,
                          1.days.ago.midnight => 1)
      end
    end

    context 'by week' do
      let(:group_by) { :week }

      before do
        Timecop.travel(3.weeks.ago) do
          send_video video_data(user_1, user_2, video_1)
          send_video video_data(user_1, user_2, video_1)
          send_video video_data(user_1, user_2, video_2)
          send_video video_data(user_1, user_2, video_3)
        end
        Timecop.travel(2.weeks.ago) do
          send_video video_data(user_1, user_2, video_4)
          send_video video_data(user_1, user_2, video_4)
          send_video video_data(user_1, user_2, video_5)
          send_video video_data(user_1, user_2, video_5)
        end
        Timecop.travel(1.weeks.ago) do
          send_video video_data(user_1, user_2, video_6)
        end
      end

      specify do
        is_expected.to eq(3.weeks.ago.beginning_of_week => 3,
                          2.weeks.ago.beginning_of_week => 2,
                          1.weeks.ago.beginning_of_week => 1)
      end
    end

    context 'by month' do
      let(:group_by) { :month }

      before do
        Timecop.travel(3.months.ago) do
          send_video video_data(user_1, user_2, video_1)
          send_video video_data(user_1, user_2, video_1)
          send_video video_data(user_1, user_2, video_2)
          send_video video_data(user_1, user_2, video_3)
        end
        Timecop.travel(2.months.ago) do
          send_video video_data(user_1, user_2, video_4)
          send_video video_data(user_1, user_2, video_4)
          send_video video_data(user_1, user_2, video_5)
          send_video video_data(user_1, user_2, video_5)
        end
        Timecop.travel(1.months.ago) do
          send_video video_data(user_1, user_2, video_6)
        end
      end

      specify do
        is_expected.to eq(3.months.ago.beginning_of_month => 3,
                          2.months.ago.beginning_of_month => 2,
                          1.months.ago.beginning_of_month => 1)
      end
    end
  end
end
