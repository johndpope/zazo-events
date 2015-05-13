require 'rails_helper'

RSpec.describe Metric::Base, type: :model do
  context 'group_by :day' do
    let(:instance) { described_class.new(group_by: :day) }

    describe '#group_by' do
      subject { instance.group_by }
      it { is_expected.to eq(:day) }
    end
  end
end
