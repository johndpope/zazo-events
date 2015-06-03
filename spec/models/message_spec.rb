require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:s3_event) { json_fixture('s3_event')['Records'] }
  let(:event) { Event.create_from_s3_event(s3_event).first }
  let(:instance) { described_class.new(event) }
  let(:sender_id) { event.data['sender_id'] }
  let(:receiver_id) { event.data['receiver_id'] }
  let(:filename) { event.data['video_filename'] }

  context '#event' do
    subject { instance.event }
    it { is_expected.to eq(event) }
  end

  context '#data' do
    subject { instance.data }
    specify do
      is_expected.to eq(
        'sender_id' => sender_id,
        'receiver_id' => receiver_id,
        'video_filename' => filename)
    end
  end

  context '#raw_params' do
    subject { instance.raw_params }
    it { is_expected.to eq(s3_event.first) }
  end

  context '#filename' do
    subject { instance.filename }
    it { is_expected.to eq(filename) }
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
      is_expected.to eq(sender_id: sender_id,
                        receiver_id: receiver_id,
                        filename: filename,
                        date: '2015-04-22T18:01:20.663Z'.to_datetime,
                        size: 94_555,
                        status: :uploaded,
                        delivered: false)
    end
  end

  context 'to_json' do
    subject { instance.to_json }
    specify do
      is_expected.to eq({ sender_id: sender_id,
                          receiver_id: receiver_id,
                          filename: filename,
                          date: '2015-04-22T18:01:20.663Z',
                          size: 94_555,
                          status: :uploaded,
                          delivered: false}.to_json)
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

  describe '#delivered?' do
    subject { instance.delivered? }

    context 'uploaded' do
      it { is_expected.to be_falsey }
    end

    context 'received' do
      before do
        receive_video instance.data
      end

      it { is_expected.to be_falsey }
    end

    context 'downloaded' do
      before do
        receive_video instance.data
        download_video instance.data
      end

      it { is_expected.to be_truthy }
    end

    context 'viewed' do
      before do
        receive_video instance.data
        download_video instance.data
        view_video instance.data
      end

      it { is_expected.to be_truthy }
    end
  end

  describe '#undelivered?' do
    subject { instance.undelivered? }

    context 'uploaded' do
      it { is_expected.to be_truthy }
    end

    context 'received' do
      before do
        receive_video instance.data
      end

      it { is_expected.to be_truthy }
    end

    context 'downloaded' do
      before do
        receive_video instance.data
        download_video instance.data
      end

      it { is_expected.to be_falsey }
    end

    context 'viewed' do
      before do
        receive_video instance.data
        download_video instance.data
        view_video instance.data
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '.all' do
    before { event.save }
    subject { described_class.all }
    it { is_expected.to eq([instance]) }
  end

  describe '.by_connection' do
    before { event.save }
    subject { described_class.by_connection(sender_id, receiver_id) }
    it { is_expected.to eq([instance]) }
  end

  describe '.find' do
    before { event.save }
    subject { described_class.find(filename) }
    it { is_expected.to eq(instance) }
  end
end
