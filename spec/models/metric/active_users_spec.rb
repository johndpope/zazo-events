require 'rails_helper'

RSpec.describe Metric::ActiveUsers, type: :model do
  let(:instance) { described_class.new(group_by: group_by) }

  describe '#generate' do
    let(:format) { '%Y-%m-%d %H:%M:%S' }
    subject { instance.generate }

    (1..13).each do |i|
      let(:"sender_#{i}") { gen_hash }
      let(:"receiver_#{i}") { gen_hash }
      let(:"video_#{i}") { gen_hash }
    end

    context 'by day' do
      let(:group_by) { :day }

      context 'dataset 1' do
        before do
          Timecop.travel(3.days.ago) do
            send_video(video_data(sender_1, receiver_1, video_1))
            send_video(video_data(sender_1, receiver_1, video_2))
            send_video(video_data(sender_1, receiver_1, video_2))

            receive_video(video_data(sender_3, receiver_3, video_3))

            receive_video(video_data(sender_4, receiver_4, video_4))
            download_video(video_data(sender_4, receiver_4, video_4))

            receive_video(video_data(sender_5, receiver_5, video_5))
            download_video(video_data(sender_5, receiver_5, video_5))
            view_video(video_data(sender_5, receiver_5, video_5))
            receive_video(video_data(sender_5, receiver_5, video_5))
            download_video(video_data(sender_5, receiver_5, video_5))
            view_video(video_data(sender_5, receiver_5, video_5))
          end
          Timecop.travel(2.days.ago) do
            send_video(video_data(sender_6, receiver_6, video_6))

            send_video(video_data(sender_7, receiver_7, video_7))
            send_video(video_data(sender_7, receiver_7, video_7))
            receive_video(video_data(sender_7, receiver_7, video_7))

            receive_video(video_data(sender_8, receiver_8, video_8))
            download_video(video_data(sender_8, receiver_8, video_8))

            receive_video(video_data(sender_9, receiver_9, video_9))
            download_video(video_data(sender_9, receiver_9, video_9))
            view_video(video_data(sender_9, receiver_9, video_9))
          end
          Timecop.travel(1.days.ago) do
            send_video(video_data(sender_10, receiver_10, video_10))

            send_video(video_data(sender_11, receiver_11, video_11))
            receive_video(video_data(sender_11, receiver_11, video_11))

            receive_video(video_data(sender_12, receiver_12, video_12))
            download_video(video_data(sender_12, receiver_12, video_12))
            view_video(video_data(sender_12, receiver_12, video_12))

            receive_video(video_data(sender_13, receiver_13, video_13))
            download_video(video_data(sender_13, receiver_13, video_13))
            view_video(video_data(sender_13, receiver_13, video_13))
          end
        end

        specify do
          is_expected.to eq(format_datetime(3.days.ago.midnight) => 2,
                            format_datetime(2.days.ago.midnight) => 3,
                            format_datetime(1.days.ago.midnight) => 4)
        end
      end

      context 'dataset 2' do
        before do
          user_1 = gen_hash
          user_2 = gen_hash
          user_3 = gen_hash
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
          is_expected.to eq(format_datetime(3.days.ago.midnight) => 3,
                            format_datetime(2.days.ago.midnight) => 2,
                            format_datetime(1.days.ago.midnight) => 2)
        end
      end
    end

    context 'by week' do
      let(:group_by) { :week }

      before do
        Timecop.travel(3.weeks.ago) do
          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(2.weeks.ago) do
          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(1.weeks.ago) do
          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
      end

      specify do
        is_expected.to eq(format_datetime(3.weeks.ago.beginning_of_week) => 2,
                          format_datetime(2.weeks.ago.beginning_of_week) => 3,
                          format_datetime(1.weeks.ago.beginning_of_week) => 4)
      end
    end

    context 'by month' do
      let(:group_by) { :month }

      before do
        Timecop.travel(3.months.ago) do
          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(2.months.ago) do
          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
        Timecop.travel(1.months.ago) do
          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          send_video(video_data(sender_id, receiver_id, video_id))
          receive_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))

          sender_id = gen_hash
          receiver_id = gen_hash
          video_id = gen_video_id
          receive_video(video_data(sender_id, receiver_id, video_id))
          download_video(video_data(sender_id, receiver_id, video_id))
          view_video(video_data(sender_id, receiver_id, video_id))
        end
      end

      specify do
        is_expected.to eq(format_datetime(3.months.ago.beginning_of_month) => 2,
                          format_datetime(2.months.ago.beginning_of_month) => 3,
                          format_datetime(1.months.ago.beginning_of_month) => 4)
      end
    end
  end
end
