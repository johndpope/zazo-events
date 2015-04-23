require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'columns' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:triggered_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:triggered_by).of_type(:string) }
    it { is_expected.to have_db_column(:initiator).of_type(:string) }
    it { is_expected.to have_db_column(:initiator_id).of_type(:string) }
    it { is_expected.to have_db_column(:target).of_type(:string) }
    it { is_expected.to have_db_column(:target_id).of_type(:string) }
    it { is_expected.to have_db_column(:raw_data).of_type(:text) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:triggered_at) }
    it { is_expected.to validate_presence_of(:triggered_by) }
    it { is_expected.to validate_presence_of(:initiator) }
    it { is_expected.to validate_presence_of(:initiator_id) }

    it { is_expected.to validate_inclusion_of(:triggered_by).in_array(%w(aws:s3 zazo:api zazo:ios zazo:android)) }
    it { is_expected.to serialize(:raw_data) }
  end

  describe '.create_from_s3_event' do
    subject { described_class.create_from_s3_event(s3_event) }

    context 'with {}' do
      let(:s3_event) { {} }
      it { is_expected.to be_nil }
    end

    context 'with nil' do
      let(:s3_event) {}
      it { is_expected.to be_nil }
    end

    context 'with ["foo"]' do
      let(:s3_event) { ['foo'] }
      it { expect { subject }.to raise_error(TypeError) }
    end

    context 'with { foo: "bar" }' do
      let(:s3_event) { { foo: 'bar' } }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'with valid data' do
      let(:s3_event) { json_fixture('event') }
      specify do
        expect(subject.first).to have_attributes(name: 'video:sent',
                                                 triggered_by: 'aws:s3',
                                                 triggered_at: '2015-04-22T18:01:20.663Z'.to_datetime,
                                                 initiator: 'user',
                                                 initiator_id: 'RxDrzAIuF9mFw7Xx9NSM',
                                                 target: 'user',
                                                 target_id: '6pqpuUZFp1zCXLykfTIx',
                                                 raw_data: s3_event['Records'].first)
      end
    end
  end
end
