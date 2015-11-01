require 'rails_helper'

RSpec.describe Metric::MessagesFailuresAutonotification, type: :model do
  let(:instance) { described_class.new }

  let(:user_1) { gen_hash }
  let(:user_2) { gen_hash }
  let(:user_3) { gen_hash }

  let(:android_receiver_platform) { { receiver_platform: 'android' } }
  let(:ios_receiver_platform)     { { receiver_platform: 'ios' } }

  let(:client_info_android_112) { { client_platform: 'android', client_version: '112' } }
  let(:client_info_android_111) { { client_platform: 'android', client_version: '111' } }
  let(:client_info_undefined)   { { client_platform: 'undefined', client_version: 'undefined' } }
  let(:client_info_ios)         { { client_platform: 'ios', client_version: 'undefined' } }

  let(:video_121) { video_data(user_1, user_2, gen_video_id).merge(android_receiver_platform) }
  let(:video_122) { video_data(user_1, user_2, gen_video_id).merge(android_receiver_platform) }
  let(:video_123) { video_data(user_1, user_2, gen_video_id).merge(android_receiver_platform) }
  let(:video_124) { video_data(user_1, user_2, gen_video_id).merge(ios_receiver_platform) }

  let(:video_131) { video_data(user_1, user_3, gen_video_id).merge(android_receiver_platform) }
  let(:video_132) { video_data(user_1, user_3, gen_video_id).merge(ios_receiver_platform) }
  let(:video_133) { video_data(user_1, user_3, gen_video_id).merge(ios_receiver_platform) }

  let(:video_211) { video_data(user_2, user_1, gen_video_id).merge(ios_receiver_platform) }
  let(:video_212) { video_data(user_2, user_1, gen_video_id).merge(android_receiver_platform) }
  let(:video_213) { video_data(user_2, user_1, gen_video_id).merge(android_receiver_platform) }
  let(:video_214) { video_data(user_2, user_1, gen_video_id).merge(android_receiver_platform) }

  before do
    Timecop.travel(12.days.ago) do
      Timecop.scale(1.day) do
        send_video video_121.merge(client_info_android_112); kvstore_receive_video video_121; notification_receive_video video_121
        send_video video_122.merge(client_info_android_111); kvstore_receive_video video_122; notification_receive_video video_122
        send_video video_123.merge(client_info_ios);         kvstore_receive_video video_123; notification_receive_video video_123
        send_video video_124.merge(client_info_undefined);   kvstore_receive_video video_124; notification_receive_video video_124

        send_video video_211.merge(client_info_android_112); kvstore_receive_video video_211; notification_receive_video video_211
        send_video video_212.merge(client_info_ios);         kvstore_receive_video video_212; notification_receive_video video_212
        send_video video_213.merge(client_info_undefined);   kvstore_receive_video video_213; notification_receive_video video_213
        send_video video_214.merge(client_info_android_112); kvstore_receive_video video_214; notification_receive_video video_214

        send_video video_131.merge(client_info_android_112); notification_receive_video video_131
        send_video video_132.merge(client_info_android_112); kvstore_receive_video video_132
        send_video video_133.merge(client_info_android_112)
      end
    end
  end

  describe '#generate' do
    subject { instance.generate }

    it do
      expected = {
        meta: {
          total: :uploaded,
          start_date: 12.days.ago.to_date,
          end_date: 2.days.ago.to_date
        },
        data: {
          ios_to_ios: {
            uploaded: 0,
            delivered: 0,
            undelivered: 0,
            incomplete: 0,
            missing_kvstore_received: 0,
            missing_notification_received: 0,
            missing_kvstore_downloaded: 0,
            missing_notification_downloaded: 0,
            missing_kvstore_viewed: 0,
            missing_notification_viewed: 0
          },
          ios_to_android: {
            uploaded: 0,
            delivered: 0,
            undelivered: 0,
            incomplete: 0,
            missing_kvstore_received: 0,
            missing_notification_received: 0,
            missing_kvstore_downloaded: 0,
            missing_notification_downloaded: 0,
            missing_kvstore_viewed: 0,
            missing_notification_viewed: 0
          },
          android_to_android: {
            uploaded: 3,
            delivered: 0,
            undelivered: 3,
            incomplete: 0,
            missing_kvstore_received: 1,
            missing_notification_received: 0,
            missing_kvstore_downloaded: 3,
            missing_notification_downloaded: 3,
            missing_kvstore_viewed: 3,
            missing_notification_viewed: 3
          },
          android_to_ios: {
            uploaded: 3,
            delivered: 0,
            undelivered: 3,
            incomplete: 1,
            missing_kvstore_received: 1,
            missing_notification_received: 2,
            missing_kvstore_downloaded: 3,
            missing_notification_downloaded: 3,
            missing_kvstore_viewed: 3,
            missing_notification_viewed: 3
          }
        }
      }
      is_expected.to eq expected
    end
  end
end
