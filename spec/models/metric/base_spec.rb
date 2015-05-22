require 'rails_helper'

RSpec.describe Metric::Base, type: :model do
  describe '#group_by' do
    let(:options) { { group_by: :day } }
    let(:instance) { described_class.new(options) }
    subject { instance.group_by }

    context 'empty' do
      let(:options) { {} }
      it { is_expected.to eq(:day) }
    end

    context 'group_by :day' do
      let(:options) { { group_by: :day } }
      it { is_expected.to eq(:day) }
    end

    context 'group_by :week' do
      let(:options) { { group_by: :week } }
      it { is_expected.to eq(:week) }
    end
  end
end
