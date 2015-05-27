require 'rails_helper'

RSpec.describe Metric::MessagesSent, type: :model, event_builders: true do
  let(:instance) { described_class.new(group_by: group_by) }

  describe '#generate' do
    subject { instance.generate }

    context 'by day' do
      let(:group_by) { :day }

      before do
        Timecop.travel(3.days.ago) do
          create_list(:event, 3)
        end
        Timecop.travel(2.days.ago) do
          create_list(:event, 2)
        end
        Timecop.travel(1.days.ago) do
          create(:event)
        end
      end

      specify do
        is_expected.to eq(3.days.ago.midnight => 3,
                          2.days.ago.midnight => 2,
                          1.days.ago.midnight => 1)
      end
    end

    context 'by week' do
      let(:group_by) { :week }

      before do
        Timecop.travel(3.weeks.ago) do
          create_list(:event, 3)
        end
        Timecop.travel(2.weeks.ago) do
          create_list(:event, 2)
        end
        Timecop.travel(1.weeks.ago) do
          create(:event)
        end
      end

      specify do
        is_expected.to eq(3.weeks.ago.beginning_of_week => 3,
                          2.weeks.ago.beginning_of_week => 2,
                          1.weeks.ago.beginning_of_week => 1)
      end
    end

    context 'by month' do
      let(:group_by) { :month }

      before do
        Timecop.travel(3.months.ago) do
          create_list(:event, 3)
        end
        Timecop.travel(2.months.ago) do
          create_list(:event, 2)
        end
        Timecop.travel(1.months.ago) do
          create(:event)
        end
      end

      specify do
        is_expected.to eq(3.months.ago.beginning_of_month => 3,
                          2.months.ago.beginning_of_month => 2,
                          1.months.ago.beginning_of_month => 1)
      end
    end
  end
end
