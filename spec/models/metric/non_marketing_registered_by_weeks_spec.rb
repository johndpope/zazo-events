require 'rails_helper'

RSpec.describe Metric::NonMarketingRegisteredByWeeks, type: :model do
  let(:instance) { described_class.new }

  let(:user_1) { gen_hash }
  let(:user_2) { gen_hash }
  let(:user_3) { gen_hash }

  describe '#generate' do
    subject { instance.generate }
    before do
      invite_at user_1, (3.weeks - 2.day).ago
      invite_at user_2, (3.weeks - 2.day).ago
      invite_at user_3, (2.weeks - 2.day).ago

      register_at user_1, (3.weeks - 1.day).ago
      register_at user_2, (2.weeks - 1.day).ago
      register_at user_2, (1.weeks - 1.day).ago
    end

    it { is_expected.to eq({
      format_datetime(3.weeks.ago.beginning_of_week) => 1,
      format_datetime(2.weeks.ago.beginning_of_week) => 1
    }) }
  end
end
