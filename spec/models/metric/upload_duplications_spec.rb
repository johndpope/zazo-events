require 'rails_helper'

RSpec.describe Metric::UploadDuplications, type: :model do
  let(:instance) { described_class.new }
  let(:user_1) { gen_hash }
  let(:user_2) { gen_hash }
  let(:user_3) { gen_hash }

  let(:video_1) { gen_video_id }
  let(:video_2) { gen_video_id }
  let(:video_3) { gen_video_id }
  let(:video_4) { gen_video_id }
  let(:video_5) { gen_video_id }
  let(:video_6) { gen_video_id }

  before do
    send_video video_data(user_1, user_2, video_1)
    send_video video_data(user_1, user_2, video_1)
    send_video video_data(user_1, user_3, video_5)
    send_video video_data(user_1, user_3, video_5)
    send_video video_data(user_2, user_1, video_2)
    send_video video_data(user_2, user_1, video_3)
    send_video video_data(user_3, user_2, video_4)
    send_video video_data(user_3, user_2, video_4)
    send_video video_data(user_3, user_2, video_4)
    send_video video_data(user_3, user_1, video_6)
    send_video video_data(user_3, user_1, video_6)
    send_video video_data(user_3, user_2, video_6)
    send_video video_data(user_3, user_2, video_6)
  end

  describe "#generate" do
    subject { instance.generate }
    it { is_expected.to eq([{ sender_id: user_3, count: 3 },
                           { sender_id: user_1, count: 2 }]) }
  end
end
