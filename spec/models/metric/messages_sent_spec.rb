require 'rails_helper'

RSpec.describe Metric::MessagesSent, type: :model do
  let(:instance) { described_class.new(group_by: group_by) }

  describe '#generate' do
    subject { instance.generate }

    context 'by day' do
      let(:group_by) { :day }

      before do
        create(:event, triggered_at: '2015-05-10 00:01:00 UTC')
        create(:event, triggered_at: '2015-05-10 00:02:00 UTC')
        create(:event, triggered_at: '2015-05-10 00:03:00 UTC')
        create(:event, triggered_at: '2015-05-11 00:01:00 UTC')
        create(:event, triggered_at: '2015-05-11 00:02:00 UTC')
        create(:event, triggered_at: '2015-05-12 00:03:00 UTC')
      end

      specify do
        is_expected.to eq('2015-05-10 00:00:00 UTC'.to_time => 3,
                          '2015-05-11 00:00:00 UTC'.to_time => 2,
                          '2015-05-12 00:00:00 UTC'.to_time => 1)
      end
    end

    context 'by week' do
      let(:group_by) { :week }

      before do
        create(:event, triggered_at: '2015-04-27 01:00:00 UTC')
        create(:event, triggered_at: '2015-04-28 02:00:00 UTC')
        create(:event, triggered_at: '2015-04-29 03:00:00 UTC')
        create(:event, triggered_at: '2015-05-05 01:00:00 UTC')
        create(:event, triggered_at: '2015-05-06 02:00:00 UTC')
        create(:event, triggered_at: '2015-05-07 03:00:00 UTC')
        create(:event, triggered_at: '2015-05-10 04:01:00 UTC')
        create(:event, triggered_at: '2015-05-11 05:02:00 UTC')
        create(:event, triggered_at: '2015-05-12 06:03:00 UTC')
      end
      specify do
        is_expected.to eq('2015-04-26 00:00:00 UTC'.to_time => 3,
                          '2015-05-03 00:00:00 UTC'.to_time => 3,
                          '2015-05-10 00:00:00 UTC'.to_time => 3)
      end
    end

    context 'by month' do
      let(:group_by) { :month }

      before do
        create(:event, triggered_at: '2015-03-01 01:00:00 UTC')
        create(:event, triggered_at: '2015-03-10 02:00:00 UTC')
        create(:event, triggered_at: '2015-03-23 03:00:00 UTC')
        create(:event, triggered_at: '2015-04-05 01:00:00 UTC')
        create(:event, triggered_at: '2015-04-16 02:00:00 UTC')
        create(:event, triggered_at: '2015-05-07 03:00:00 UTC')
        create(:event, triggered_at: '2015-05-10 04:01:00 UTC')
        create(:event, triggered_at: '2015-05-11 05:02:00 UTC')
        create(:event, triggered_at: '2015-05-12 06:03:00 UTC')
      end
      specify do
        is_expected.to eq('2015-03-01 00:00:00 UTC'.to_time => 3,
                          '2015-04-01 00:00:00 UTC'.to_time => 2,
                          '2015-05-01 00:00:00 UTC'.to_time => 4)
      end
    end
  end
end
