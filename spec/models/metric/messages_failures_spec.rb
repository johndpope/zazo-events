require 'rails_helper'

RSpec.describe Metric::MessagesFailures, type: :model do
  let(:instance) { described_class.new }
  let(:user_1) { gen_hash }
  let(:user_2) { gen_hash }

  let(:video_121) { video_data user_1, user_2, gen_video_id }
  let(:video_122) { video_data user_1, user_2, gen_video_id }
  let(:video_123) { video_data user_1, user_2, gen_video_id }
  let(:video_124) { video_data user_1, user_2, gen_video_id }
  let(:video_125) { video_data user_1, user_2, gen_video_id }
  let(:video_126) { video_data user_1, user_2, gen_video_id }
  let(:video_127) { video_data user_1, user_2, gen_video_id }

  let(:video_211) { video_data user_2, user_1, gen_video_id }
  let(:video_212) { video_data user_2, user_1, gen_video_id }
  let(:video_213) { video_data user_2, user_1, gen_video_id }
  let(:video_214) { video_data user_2, user_1, gen_video_id }
  let(:video_215) { video_data user_2, user_1, gen_video_id }
  let(:video_216) { video_data user_2, user_1, gen_video_id }

  before do
    Timecop.travel(13.days.ago) do
      # not inclued messages
      video_flow video_121
      video_flow video_211
    end
    Timecop.travel(12.days.ago) do
      Timecop.scale(1.day) do
        send_video video_122
        receive_video video_122
        kvstore_download_video video_122

        send_video video_123
        kvstore_receive_video video_123
        notification_download_video video_123

        send_video video_124
        notification_receive_video video_124
        download_video video_124

        send_video video_125
        receive_video video_125
        download_video video_125
        kvstore_view_video video_125

        send_video video_126
        receive_video video_126
        notification_download_video video_126
        notification_view_video video_126

        send_video video_127

        send_video video_212
        notification_download_video video_212
        notification_view_video video_212

        send_video video_213
        receive_video video_213
        kvstore_download_video video_213
        kvstore_view_video video_213

        send_video video_214
        kvstore_receive_video video_214
        download_video video_214
        kvstore_view_video video_214

        send_video video_215
        notification_receive_video video_215
        kvstore_download_video video_215
        notification_view_video video_215

        send_video video_216
        receive_video video_216
      end
    end
  end

  describe '#generate' do
    subject { instance.generate }
    specify do
      is_expected.to eq(uploaded: 11,
                        delivered: 9,
                        undelivered: 2,
                        incomplete: 1,
                        missing_kvstore_received: 4,
                        missing_notification_received: 4,
                        missing_kvstore_downloaded: 5,
                        missing_notification_downloaded: 5,
                        missing_kvstore_viewed: 8,
                        missing_notification_viewed: 8)
    end
  end
end
