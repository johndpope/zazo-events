require 'rails_helper'

RSpec.describe Metric::Base, type: :model, metric: true do
  let(:instance) { described_class.new(foo: 'bar') }

  describe '#attributes' do
    subject { instance.attributes }
    it { is_expected.to eq('foo' => 'bar') }
  end

  describe '.metric_name' do
    subject { described_class.metric_name }
    it { is_expected.to eq('base') }
  end

  describe '.to_hash' do
    subject { described_class.to_hash }
    it { is_expected.to eq(name: described_class.name, metric_name: 'base', type: :metric) }
  end

  describe '.to_json' do
    subject { described_class.to_json }
    it { is_expected.to eq({ name: described_class.name, metric_name: 'base', type: :metric }.to_json) }
  end
end
