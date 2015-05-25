require 'rails_helper'

RSpec.describe Metric::Base, type: :model, metric: true do
  let(:instance) { described_class.new(foo: 'bar') }

  describe '#attributes' do
    subject { instance.attributes }
    it { is_expected.to eq('foo' => 'bar') }
  end
end
