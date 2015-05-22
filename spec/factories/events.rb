FactoryGirl.define do
  factory :event do
    name %w(video s3 uploaded)
    triggered_at { DateTime.now }
    triggered_by 'aws:s3'
    initiator 's3'
    target 'video'
    target_id 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998'
    message_id { Digest::UUID.uuid_v4 }

    trait :triggered_by_api do
      triggered_by 'zazo:api'
    end

    trait :initiator_user do
      initiator 'user'
    end

    trait :target_user do
      target 'user'
    end

    trait :video_s3_uploaded do
      name %w(video s3 uploaded)
      triggered_by 'aws:s3'
      initiator 's3'
    end

    trait :video_kvstore_received do
      name %w(video kvstore received)
      triggered_by_api
      initiator_user
    end

    trait :video_kvstore_downloaded do
      name %w(video kvstore downloaded)
      triggered_by_api
      initiator_user
    end

    trait :video_kvstore_viewed do
      name %w(video kvstore viewed)
      triggered_by_api
      initiator_user
    end

    trait :video_notification_received do
      name %w(video notification received)
      triggered_by_api
      initiator_user
    end

    trait :video_notification_downloaded do
      name %w(video notification downloaded)
      triggered_by_api
      initiator_user
    end

    trait :video_notification_viewed do
      name %w(video notification viewed)
      triggered_by_api
      initiator_user
    end

    trait :user_initialized do
      name %w(user initialized)
      triggered_by_api
      initiator_user
      data(event: :pend!, from_state: :registered, to_state: :initialized)
    end

    trait :user_invited do
      name %w(user invited)
      triggered_by_api
      initiator_user
      data(event: :invite!, from_state: :initialized, to_state: :invited)
    end

    trait :user_registered do
      name %w(user registered)
      triggered_by_api
      initiator_user
      data(event: :register!, from_state: :initialized, to_state: :registered)
    end

    trait :user_verified do
      name %w(user verified)
      triggered_by_api
      initiator_user
      data(event: :verify!, from_state: :registered, to_state: :verified)
    end

    trait :user_invitation_sent do
      name %w(user invitation_sent)
      triggered_by_api
      initiator_user
      target_user
    end

    trait :connection_established do
      name %w(connection established)
      triggered_by_api
      initiator 'connection'
      data(event: :establish!, from_state: :voided, to_state: :established)
    end
  end
end
