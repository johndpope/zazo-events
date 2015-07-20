require 'rails_helper'

RSpec.describe Metric::VerifiedAfterNthNotification, type: :model do
  let(:instance) { described_class.new users_data: users_data }

  let(:user_1) { gen_hash }
  let(:user_2) { gen_hash }
  let(:user_3) { gen_hash }

  describe '#generate' do
    subject { instance.generate }
    let :users_data do
      [
        { user_id: user_1, msg_order: 1, sent_at: Time.now - 1.days,   next_sent_at: Time.now + 1.days },
        { user_id: user_2, msg_order: 1, sent_at: Time.now,            next_sent_at: Time.now + 3.days },
        { user_id: user_3, msg_order: 1, sent_at: Time.now,            next_sent_at: Time.now + 1.days },
        { user_id: user_3, msg_order: 2, sent_at: Time.now + 25.hours, next_sent_at: Time.now + 10.years }
      ].map &:stringify_keys
    end

    before do
      verify_at user_1, Time.now
      verify_at user_2, Time.now + 1.days
      verify_at user_3, Time.now + 2.days
    end

    specify { is_expected.to eq({ '1' => 2, '2' => 1 }) }
  end
end
