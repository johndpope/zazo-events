require 'rails_helper'

RSpec.describe Metric::Base, type: :model, metric: true do
  describe '#options' do
    subject { described_class.new(foo: 'bar').options }
    it { is_expected.to eq(foo: 'bar') }
  end
end
