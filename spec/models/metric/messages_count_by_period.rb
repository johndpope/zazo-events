require 'rails_helper'

RSpec.describe Metric::MessagesCountByPeriod, type: :model do
  let(:instance) { described_class.new(attributes) }

  let(:user)     { gen_hash }
  let(:friend_1) { gen_hash }
  let(:friend_2) { gen_hash }

  let(:video_121) { video_data(user, friend_1, gen_video_id) }
  let(:video_122) { video_data(user, friend_1, gen_video_id) }
  let(:video_123) { video_data(user, friend_1, gen_video_id) }
  let(:video_124) { video_data(user, friend_1, gen_video_id) }

  let(:video_131) { video_data(user, friend_2, gen_video_id) }
  let(:video_132) { video_data(user, friend_2, gen_video_id) }
  let(:video_133) { video_data(user, friend_2, gen_video_id) }
  let(:video_134) { video_data(user, friend_2, gen_video_id) }


  describe 'validations' do
    it { is_expected.to validate_presence_of(:user_id) }
  end

  describe '#user_id' do
    subject { instance.user_id }

    context 'RxDrzAIuF9mFw7Xx9NSM' do
      let(:attributes) { { user_id: 'RxDrzAIuF9mFw7Xx9NSM' } }
      it { is_expected.to eq('RxDrzAIuF9mFw7Xx9NSM') }
    end
  end

  describe '#generate' do
    subject { instance.generate }

    before do
      # 1 -> 2
      Timecop.travel(4.days.ago) { video_flow video_121 }
      Timecop.travel(3.days.ago) { video_flow video_122 }
      Timecop.travel(2.days.ago) { video_flow video_123 }
      Timecop.travel(1.days.ago) { video_flow video_124 }

      # 1 -> 3
      Timecop.travel(3.days.ago) { video_flow video_131 }
      Timecop.travel(2.days.ago) { video_flow video_132 }
      Timecop.travel(1.days.ago) { video_flow video_133 }
      video_flow video_134
    end

    context 'by day' do
      let(:attributes) { { user_id: user } }

      specify do
        result = {
            4.days.ago.midnight => 1,
            3.days.ago.midnight => 2,
            2.days.ago.midnight => 2,
            1.days.ago.midnight => 2,
            Date.today.midnight => 1
        }
        is_expected.to eq(result)
      end
    end
  end
end
