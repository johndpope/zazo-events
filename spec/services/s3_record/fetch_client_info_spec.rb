require 'rails_helper'

RSpec.describe S3Record::FetchClientInfo do
  let(:instance) { described_class.new s3_record }

  describe '#do' do
    let(:undefined_client_info) { { client_version: :undefined, client_platform: :undefined } }
    subject { instance.do }

    context 'when s3 file contains metadata' do
      use_vcr_cassette 's3_record/s3_metadata_with_client_version'
      let(:s3_record) { json_fixture('s3_event_with_metadata')['Records'].first }

      it { is_expected.to eq({ client_version: '112', client_platform: 'android' }) }
      it do
        expect(Rollbar).to_not receive(:error)
        subject
      end
    end

    context 'when s3 file doesn\'t contain metadata' do
      use_vcr_cassette 's3_record/s3_metadata_without_client_version'
      let(:s3_record) { json_fixture('s3_event_without_metadata')['Records'].first }

      it { is_expected.to eq undefined_client_info }
      it do
        expect(Rollbar).to_not receive(:error)
        subject
      end
    end

    context 'when s3 file doesn\'t exist' do
      use_vcr_cassette 's3_record/s3_metadata_file_not_exist'
      let(:s3_record) { json_fixture('s3_event')['Records'].first }

      it { is_expected.to eq undefined_client_info }
      it do
        expect(Rollbar).to receive(:error).with exception: 'Aws::S3::Errors::Forbidden', message: instance_of(String)
        subject
      end
    end

    context 'when s3 record is incorrect' do
      let(:s3_record) { json_fixture('s3_event_incorrect')['Records'].first }

      it { is_expected.to eq undefined_client_info }
      it do
        expect(Rollbar).to receive(:error).with exception: 'ArgumentError', message: instance_of(String)
        subject
      end
    end
  end
end
