require 'rails_helper'

RSpec.describe Metric::OnboardingInfo, type: :model do
  let(:instance) { described_class.new }

  let(:user_1) { gen_hash }
  let(:user_2) { gen_hash }
  let(:user_3) { gen_hash }

  let(:video_12) { video_data(user_1, user_2, gen_video_id) }
  let(:video_13) { video_data(user_1, user_3, gen_video_id) }
  let(:video_31) { video_data(user_3, user_2, gen_video_id) }

  describe '#generate' do
    subject { instance.generate }

    before do
      video_flow video_12
      video_flow video_13
      video_flow video_31
    end

    specify do
      result = {
        'active'     => { Date.today.midnight.to_s => 2 },
        'invited'    => { Date.today.midnight.to_s => 0 },
        'registered' => { Date.today.midnight.to_s => 0 },
        'verified'   => { Date.today.midnight.to_s => 0 }
      }
      is_expected.to eq(result)
    end
  end
end
