require 'rails_helper'

RSpec.describe Message, type: :model do
  let(:s3_event_raw) { json_fixture('s3_event')['Records'] }
  let(:s3_event) { Event.create_from_s3_event(s3_event_raw).first }
  let(:filename) { s3_event.video_filename }
  let(:sender_id) { s3_event.sender_id }
  let(:receiver_id) { s3_event.receiver_id }
  let(:message) { described_class.new(filename) }
  let(:instance) { message }

  describe 'initialize' do
    context 'by filename' do
      let(:instance) { described_class.new(filename) }

      context '#filename' do
        subject { instance.filename }
        it { is_expected.to eq(filename) }
      end

      context '#s3_event' do
        subject { instance.s3_event }
        it { is_expected.to eq(s3_event) }
      end
    end

    context 'by s3 event' do
      let(:instance) { described_class.new(s3_event) }

      context '#filename' do
        subject { instance.filename }
        it { is_expected.to eq(filename) }
      end

      context '#s3_event' do
        subject { instance.s3_event }
        it { is_expected.to eq(s3_event) }
      end
    end

    context 'by not s3 event' do
      subject { described_class.new(build(:event, :video_kvstore_received)) }

      specify do
        expect { subject }.to raise_error(TypeError, 'value must be either filename or video:s3:uploaded event')
      end
    end
  end

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

    context 'with events given in initializer' do
      let(:instance) { described_class.new(filename, []) }

      specify do
        expect(Event).to_not receive(:with_video_filename).with(filename)
        subject
      end
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

  context '#id' do
    subject { instance.id }
    it { is_expected.to eq(filename) }
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
      is_expected.to eq(id: filename,
                        sender_id: sender_id,
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
      is_expected.to eq({ id: filename,
                          sender_id: sender_id,
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

  describe '.all' do
    let!(:message_1) { described_class.new(send_video(video_data(sender_id, receiver_id, gen_video_id))) }
    let!(:message_2) { described_class.new(send_video(video_data(gen_hash, receiver_id, gen_video_id))) }
    let!(:message_3) { described_class.new(send_video(video_data(sender_id, gen_hash, gen_video_id))) }
    let(:options) { {} }
    let(:list) { described_class.all(options) }
    let(:instance) { list.first }
    subject { list }

    it { is_expected.to eq([message, message_1, message_2, message_3]) }

    context 'first' do
      subject { instance }

      context '#events' do
        subject { instance.events }

        it { is_expected.to all(be_an(Event)) }

        specify do
          expect(Event).to_not receive(:with_video_filename).with(filename)
          subject
        end

        it 'all with specified video_filename' do
          is_expected.to all(satisfy { |e| e.video_filename == filename })
        end
      end
    end

    context 'reverse' do
      let(:options) { { reverse: true } }
      it { is_expected.to eq([message_3, message_2, message_1, message]) }
    end

    context 'when sender_id given' do
      let(:options) { { sender_id: sender_id } }
      it { is_expected.to eq([message, message_1, message_3]) }
    end

    context 'when receiver_id given' do
      let(:options) { { receiver_id: receiver_id } }
      it { is_expected.to eq([message, message_1, message_2]) }
    end
  end
end
