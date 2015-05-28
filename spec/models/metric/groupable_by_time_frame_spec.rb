require 'rails_helper'

class TestGroupableByTimeFrame < Metric::Base
  include Metric::GroupableByTimeFrame
end

RSpec.describe Metric::GroupableByTimeFrame, type: :model do
  let(:instance) { TestGroupableByTimeFrame.new(attributes) }

  describe 'validations' do
    subject { TestGroupableByTimeFrame.new }
    it { is_expected.to validate_presence_of(:group_by) }
    it { is_expected.to validate_inclusion_of(:group_by).in_array(Groupdate::FIELDS) }
  end

  describe '#group_by' do
    let(:attributes) { { group_by: :day } }
    subject { instance.group_by }

    context 'empty' do
      let(:attributes) { {} }
      it { is_expected.to eq(:day) }
    end

    context 'group_by :day' do
      let(:attributes) { { group_by: :day } }
      it { is_expected.to eq(:day) }
    end

    context 'group_by :week' do
      let(:attributes) { { group_by: :week } }
      it { is_expected.to eq(:week) }
    end
  end

  describe '.type' do
    subject { TestGroupableByTimeFrame.type }
    it { is_expected.to eq(:aggregated_by_timeframe) }
  end
end
