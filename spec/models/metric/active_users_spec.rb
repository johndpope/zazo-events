require 'rails_helper'

RSpec.describe Metric::ActiveUsers, type: :model do
  include EventBuilders

  let(:instance) { described_class.new(group_by: group_by) }

  describe '#generate' do
    subject { instance.generate }

    context 'by day' do
      let(:group_by) { :day }

      context 'dataset 1' do
        before do
          Timecop.travel(3.days.ago) do
            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            send_video(video_data(sender_id, receiver_id, video_id))
            send_video(video_data(sender_id, receiver_id, video_id))

            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            receive_video(video_data(sender_id, receiver_id, video_id))

            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            receive_video(video_data(sender_id, receiver_id, video_id))
            download_video(video_data(sender_id, receiver_id, video_id))

            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            receive_video(video_data(sender_id, receiver_id, video_id))
            download_video(video_data(sender_id, receiver_id, video_id))
            view_video(video_data(sender_id, receiver_id, video_id))
            receive_video(video_data(sender_id, receiver_id, video_id))
            download_video(video_data(sender_id, receiver_id, video_id))
            view_video(video_data(sender_id, receiver_id, video_id))
          end
          Timecop.travel(2.days.ago) do
            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            send_video(video_data(sender_id, receiver_id, video_id))

            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            send_video(video_data(sender_id, receiver_id, video_id))
            receive_video(video_data(sender_id, receiver_id, video_id))

            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            receive_video(video_data(sender_id, receiver_id, video_id))
            download_video(video_data(sender_id, receiver_id, video_id))

            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            receive_video(video_data(sender_id, receiver_id, video_id))
            download_video(video_data(sender_id, receiver_id, video_id))
            view_video(video_data(sender_id, receiver_id, video_id))
          end
          Timecop.travel(1.days.ago) do
            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            send_video(video_data(sender_id, receiver_id, video_id))

            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            send_video(video_data(sender_id, receiver_id, video_id))
            receive_video(video_data(sender_id, receiver_id, video_id))

            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            receive_video(video_data(sender_id, receiver_id, video_id))
            download_video(video_data(sender_id, receiver_id, video_id))
            view_video(video_data(sender_id, receiver_id, video_id))

            sender_id = gen_user_id
            receiver_id = gen_user_id
            video_id = gen_video_id
            receive_video(video_data(sender_id, receiver_id, video_id))
            download_video(video_data(sender_id, receiver_id, video_id))
            view_video(video_data(sender_id, receiver_id, video_id))
          end
        end

        specify do
          is_expected.to eq(3.days.ago.midnight => 2,
                            2.days.ago.midnight => 3,
                            1.days.ago.midnight => 4)
        end
      end

      context 'dataset 2' do
        before do
          user_1 = gen_user_id
          user_2 = gen_user_id
          user_3 = gen_user_id
          Timecop.travel(3.days.ago) do
            video_id = gen_video_id
            send_video(video_data(user_1, user_2, video_id))
            send_video(video_data(user_2, user_3, video_id))
            receiver_video_flow(video_data(user_2, user_3, video_id))
          end
          Timecop.travel(2.days.ago) do
            video_id = gen_video_id
            send_video(video_data(user_1, user_2, video_id))
            receiver_video_flow(video_data(user_2, user_3, video_id))
            video_id = gen_video_id
            send_video(video_data(user_1, user_3, video_id))
            receiver_video_flow(video_data(user_1, user_3, video_id))
          end
          Timecop.travel(1.day.ago) do
            video_id = gen_video_id
            send_video(video_data(user_1, user_2, video_id))
            receiver_video_flow(video_data(user_1, user_2, video_id))
            video_id = gen_video_id
            send_video(video_data(user_2, user_3, video_id))
            receive_video(video_data(user_2, user_3, video_id))
            download_video(video_data(user_2, user_3, video_id))
          end
        end
        specify do
          is_expected.to eq(3.days.ago.midnight => 3,
                            2.days.ago.midnight => 2,
                            1.days.ago.midnight => 2)
        end
      end
    end

    context 'by week' do
      let(:group_by) { :week }

      before do
        Timecop.travel(3.weeks.ago) do
          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(2.weeks.ago) do
          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(1.weeks.ago) do
          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
      end

      specify do
        is_expected.to eq(3.weeks.ago.beginning_of_week => 2,
                          2.weeks.ago.beginning_of_week => 3,
                          1.weeks.ago.beginning_of_week => 4)
      end
    end

    context 'by month' do
      let(:group_by) { :month }

      before do
        Timecop.travel(3.months.ago) do
          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(2.months.ago) do
          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(1.months.ago) do
          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_user_id
          receiver_id = gen_user_id
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
      end

      specify do
        is_expected.to eq(3.months.ago.beginning_of_month => 2,
                          2.months.ago.beginning_of_month => 3,
                          1.months.ago.beginning_of_month => 4)
      end
    end
  end
end
