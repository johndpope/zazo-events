require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:s3_event) { json_fixture('s3_event')['Records'] }
  let(:event) { Event.create_from_s3_event(s3_event).first }

  let(:instance) { described_class.new(event) }

  context '#event' do
    subject { instance.event }
    it { is_expected.to eq(event) }
  end

  context '#data' do
    subject { instance.data }
    specify do
      is_expected.to eq(
        'sender_id' => 'RxDrzAIuF9mFw7Xx9NSM',
        'receiver_id' => '6pqpuUZFp1zCXLykfTIx',
        'video_filename' => 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998')
    end
  end

  context '#raw_params' do
    subject { instance.raw_params }
    it { is_expected.to eq(s3_event.first) }
  end

  context '#filename' do
    subject { instance.filename }
    it { is_expected.to eq('RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998') }
  end

  context '#date' do
    subject { instance.date }
    it { is_expected.to eq(event.triggered_at) }
  end

  context '#size' do
    subject { instance.size }
    it { is_expected.to eq(94_555) }
  end

  context 'to_hash' do
    subject { instance.to_hash }
    specify do
      is_expected.to eq(sender_id: 'RxDrzAIuF9mFw7Xx9NSM',
                        receiver_id: '6pqpuUZFp1zCXLykfTIx',
                        filename: 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998',
                        date: '2015-04-22T18:01:20.663Z'.to_datetime,
                        size: 94_555)
    end
  end

  context 'to_json' do
    subject { instance.to_json }
    specify do
      is_expected.to eq({ sender_id: 'RxDrzAIuF9mFw7Xx9NSM',
                          receiver_id: '6pqpuUZFp1zCXLykfTIx',
                          filename: 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998',
                          date: '2015-04-22T18:01:20.663Z',
                          size: 94_555 }.to_json)
    end
  end

  describe '#status' do
    subject { instance.status }

    context 'uploaded' do
      before do
        instance
      end

      it { is_expected.to eq(:uploaded) }
    end

    context 'received' do
      before do
        receive_video instance.data
      end

      it { is_expected.to eq(:received) }
    end

    context 'downloaded' do
      before do
        receive_video instance.data
        download_video instance.data
      end

      it { is_expected.to eq(:downloaded) }
    end

    context 'viewed' do
      before do
        receive_video instance.data
        download_video instance.data
        view_video instance.data
      end

      it { is_expected.to eq(:viewed) }
    end
  end
end
