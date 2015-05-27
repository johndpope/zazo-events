require 'rails_helper'

RSpec.describe Event, type: :model, event_builders: true do
  let(:message_id) { Digest::UUID.uuid_v4 }

  describe 'columns' do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(array: true) }
    it { is_expected.to have_db_column(:triggered_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:triggered_by).of_type(:string) }
    it { is_expected.to have_db_column(:initiator).of_type(:string) }
    it { is_expected.to have_db_column(:initiator_id).of_type(:string) }
    it { is_expected.to have_db_column(:target).of_type(:string) }
    it { is_expected.to have_db_column(:target_id).of_type(:string) }
    it { is_expected.to have_db_column(:data).of_type(:json) }
    it { is_expected.to have_db_column(:raw_params).of_type(:json) }
    it { is_expected.to have_db_column(:message_id).of_type(:uuid) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:triggered_at) }
    it { is_expected.to validate_presence_of(:triggered_by) }
    it { is_expected.to validate_presence_of(:initiator) }

    it { is_expected.to validate_inclusion_of(:triggered_by).in_array(%w(aws:s3 zazo:api zazo:ios zazo:android)) }
  end

  describe '.create_from_s3_event' do
    subject { described_class.create_from_s3_event(s3_event) }

    context 'with nil' do
      let(:s3_event) {}
      it { is_expected.to eq([]) }
    end

    context 'with {}' do
      let(:s3_event) { {} }
      it { expect { subject }.to raise_error(ArgumentError) }
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
      let(:s3_event) { json_fixture('s3_event')['Records'] }
      specify do
        expect(subject.first).to have_attributes(name: %w(video s3 uploaded),
                                                 triggered_by: 'aws:s3',
                                                 triggered_at: '2015-04-22T18:01:20.663Z'.to_datetime,
                                                 initiator: 's3',
                                                 initiator_id: nil,
                                                 target: 'video',
                                                 target_id: 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998',
                                                 data: { 'sender_id' => 'RxDrzAIuF9mFw7Xx9NSM',
                                                         'receiver_id' => '6pqpuUZFp1zCXLykfTIx',
                                                         'video_filename' => 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998' },
                                                 raw_params: s3_event.first)
      end
    end
  end

  describe '.create_from_params' do
    let(:s3_event) { json_fixture('s3_event')['Records'] }
    subject { described_class.create_from_params(params, message_id) }

    context 'for S3 event' do
      let(:params) { s3_event }
      specify do
        expect(described_class).to receive(:create_from_s3_event).with(params, message_id)
        subject
      end
    end

    context 'for valid params' do
      let(:params) do
        { name: %w(video notification received),
          triggered_at: Time.now,
          triggered_by: 'zazo:api',
          initiator: 'user',
          initiator_id: '6pqpuUZFp1zCXLykfTIx' }
      end

      specify do
        is_expected.to have_attributes(params.merge(raw_params: nil, message_id: message_id))
      end
      it { is_expected.to be_valid }

      context 'when name is string' do
        let(:params) do
          { name: 'video:notification:received',
            triggered_at: Time.now,
            triggered_by: 'zazo:api',
            initiator: 'user',
            initiator_id: '6pqpuUZFp1zCXLykfTIx' }
        end

        specify do
          is_expected.to have_attributes(params.merge(raw_params: nil,
                                                      message_id: message_id,
                                                      name: %w(video notification received)))
        end
        it { is_expected.to be_valid }
      end
    end

    context 'for invalid params' do
      let(:params) do
        { name: %w(video notification received),
          triggered_by: 'zazo:api',
          initiator: 'user',
          initiator_id: '6pqpuUZFp1zCXLykfTIx' }
      end

      it { is_expected.to_not be_valid }
    end

    context 'for duplicated message' do
      let(:params) do
        { name: %w(video notification received),
          triggered_at: Time.now,
          triggered_by: 'zazo:api',
          initiator: 'user',
          initiator_id: '6pqpuUZFp1zCXLykfTIx' }
      end
      before { create(:event, message_id: message_id) }
      specify do
        expect { subject }.to_not change { described_class.count }
      end
    end
  end

  describe '.by_tokens' do
    let(:token) { user_id }
    subject { described_class.by_tokens(token).order(:triggered_at) }

    context 'dataset 1' do
      let(:user_1) { gen_hash }
      let(:user_2) { gen_hash }
      let(:video_1) { gen_video_id }
      let(:video_2) { gen_video_id }

      before do
        @user_1_activity = []
        @user_2_activity = []
        e = build(:event, :user_initialized, initiator_id: user_1)
        e.initiator = 'user'
        e.save && @user_1_activity << e
        e = build(:event, :user_registered, initiator_id: user_1)
        e.initiator = 'user'
        e.save && @user_1_activity << e
        e = build(:event, :user_verified, initiator_id: user_1)
        e.initiator = 'user'
        e.save && @user_1_activity << e
        video_events_1 = video_flow video_data(user_1, user_2, video_1)
        @user_1_activity += video_events_1
        @user_2_activity += video_events_1
        e = build(:event, :user_initialized, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        e = build(:event, :user_invited, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        e = build(:event, :connection_established,
                  initiator_id: "1_2_#{gen_hash}")
        e.initiator = 'connection'
        e.save
        invitation = build(:event, :user_invitation_sent,
                           initiator_id: user_1,
                           target_id: user_2,
                           data: invitation_data(user_1, user_2))
        invitation.initiator = 'user'
        invitation.target = 'user'
        invitation.save
        @user_1_activity << invitation
        @user_2_activity << invitation
        e = build(:event, :user_registered, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        e = build(:event, :user_verified, initiator_id: user_2)
        e.initiator = 'user'
        e.save && @user_2_activity << e
        video_events_2 = video_flow video_data(user_2, user_1, video_2)
        @user_1_activity += video_events_2
        @user_2_activity += video_events_2
      end

      context 'user_1' do
        let(:token) { user_1 }
        it { is_expected.to eq(@user_1_activity) }
      end

      context 'user_2' do
        let(:token) { user_2 }
        it { is_expected.to eq(@user_2_activity) }
      end
    end
  end
end
