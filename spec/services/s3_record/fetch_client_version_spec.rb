require 'rails_helper'

RSpec.describe S3Record::FetchClientVersion do
  let(:instance) { described_class.new s3_record }

  describe '#do' do
    subject { instance.do }

    context 'when s3 file contains metadata' do
      use_vcr_cassette 's3_record/s3_metadata_with_client_version'
      let(:s3_record) { json_fixture('s3_event_with_metadata')['Records'] }

      it { is_expected.to eq '112' }
    end

    context 'when s3 file doesn\'t contain metadata' do
      use_vcr_cassette 's3_record/s3_metadata_without_client_version'
      let(:s3_record) { json_fixture('s3_event_without_metadata')['Records'] }

      it { is_expected.to eq :undefined }
    end

    context 'when s3 file doesn\'t exist' do
      use_vcr_cassette 's3_record/s3_metadata_file_not_exist'
      let(:s3_record) { json_fixture('s3_event')['Records'] }

      it { is_expected.to eq :undefined }
      it do
        expect(Rollbar).to receive(:error).with exception: 'Aws::S3::Errors::Forbidden', message: instance_of(String)
        subject
      end
    end

    context 'when s3 record is incorrect' do
      let(:s3_record) { json_fixture('s3_event_incorrect')['Records'] }

      it { is_expected.to eq :undefined }
      it do
        expect(Rollbar).to receive(:error).with exception: 'ArgumentError', message: instance_of(String)
        subject
      end
    end
  end
end
