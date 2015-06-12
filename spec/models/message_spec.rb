require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:s3_event_raw) { json_fixture('s3_event')['Records'] }
  let(:s3_event) { Event.create_from_s3_event(s3_event_raw).first }
  let(:filename) { s3_event.data['video_filename'] }
  let(:sender_id) { s3_event.data['sender_id'] }
  let(:receiver_id) { s3_event.data['receiver_id'] }
  let(:instance) { described_class.new(filename) }

  context '#events' do
    subject { instance.events }

    context 'only when S3 uploaded' do
      it { is_expected.to eq([s3_event]) }
    end

    context 'all' do
      let(:events) do
        result = [s3_event]
        result += receive_video(s3_event.data)
        result += download_video(s3_event.data)
        result += view_video(s3_event.data)
        result
      end
      it { is_expected.to eq(events) }
    end
  end

  context '#s3_event' do
    subject { instance.s3_event }
    it { is_expected.to eq(s3_event) }

    context 'no s3 event found' do
      let(:filename) { 'unknown' }
      specify do
        expect { subject }.to raise_error('no video:s3:uploaded event found')
      end
    end
  end

  context '#data' do
    subject { s3_event.data }
    specify do
      is_expected.to eq(
        'sender_id' => sender_id,
        'receiver_id' => receiver_id,
        'video_filename' => filename)
    end
  end

  context '#raw_params' do
    subject { instance.raw_params }
    it { is_expected.to eq(Hashie::Mash.new(s3_event.raw_params)) }
  end

  context '#filename' do
    subject { instance.filename }
    it { is_expected.to eq(filename) }
  end

  context '#date' do
    subject { instance.date }
    it { is_expected.to eq(s3_event.triggered_at) }
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
                          delivered: false }.to_json)
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
        receive_video s3_event.data
      end

      it { is_expected.to eq(:received) }
    end

    context 'downloaded' do
      before do
        receive_video s3_event.data
        download_video s3_event.data
      end

      it { is_expected.to eq(:downloaded) }
    end

    context 'viewed' do
      before do
        receive_video s3_event.data
        download_video s3_event.data
        view_video s3_event.data
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
        receive_video s3_event.data
      end

      it { is_expected.to be_falsey }
    end

    context 'downloaded' do
      before do
        receive_video s3_event.data
        download_video s3_event.data
      end

      it { is_expected.to be_truthy }
    end

    context 'viewed' do
      before do
        receive_video s3_event.data
        download_video s3_event.data
        view_video s3_event.data
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
        receive_video s3_event.data
      end

      it { is_expected.to be_truthy }
    end

    context 'downloaded' do
      before do
        receive_video s3_event.data
        download_video s3_event.data
      end

      it { is_expected.to be_falsey }
    end

    context 'viewed' do
      before do
        receive_video s3_event.data
        download_video s3_event.data
        view_video s3_event.data
      end

      it { is_expected.to be_falsey }
    end
  end

  describe '.by_direction' do
    before { s3_event.save }
    let(:by_direction) { described_class.by_direction(sender_id, receiver_id) }
    let(:instance) { by_direction.first }
    subject { by_direction }

    it { is_expected.to be_a(Array) }
    it { is_expected.to all(be_a(Message)) }

    context 'first' do
      subject { instance }
      context '#events' do
        subject { instance.events }
        it { is_expected.to all(be_an(Event)) }
        it 'all with specified video_filename' do
          is_expected.to all(satisfy { |e| e.data['video_filename'] == filename })
        end
      end
    end
  end
end
