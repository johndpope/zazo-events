FactoryGirl.define do
  factory :event do
    name %w(video s3 uploaded)
    triggered_at { DateTime.now }
    triggered_by 'aws:s3'
    initiator 's3'
    target 'video'
    target_id 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998'
    message_id { Digest::UUID.uuid_v4 }

    trait :video_s3_uploaded do
      name %w(video s3 uploaded)
      triggered_by 'aws:s3'
      initiator 's3'
    end

    trait :video_kvstore_received do
      name %w(video kvstore received)
      triggered_by 'zazo:api'
      initiator 'user'
    end

    trait :video_kvstore_downloaded do
      name %w(video kvstore downloaded)
      triggered_by 'zazo:api'
      initiator 'user'
    end

    trait :video_kvstore_viewed do
      name %w(video kvstore viewed)
      triggered_by 'zazo:api'
      initiator 'user'
    end

    trait :video_notification_received do
      name %w(video notification received)
      triggered_by 'zazo:api'
      initiator 'user'
    end

    trait :video_notification_downloaded do
      name %w(video notification downloaded)
      triggered_by 'zazo:api'
      initiator 'user'
    end

    trait :video_notification_viewed do
      name %w(video notification viewed)
      triggered_by 'zazo:api'
      initiator 'user'
    end

    factory :video_s3_uploaded_event, traits: [:video_s3_uploaded]
    factory :video_kvstore_received_event, traits: [:video_kvstore_received]
    factory :video_kvstore_downloaded_event, traits: [:video_kvstore_downloaded]
    factory :video_kvstore_viewed_event, traits: [:video_kvstore_viewed]
    factory :video_notification_received_event, traits: [:video_notification_received]
    factory :video_notification_downloaded_event, traits: [:video_notification_downloaded]
    factory :video_notification_viewed_event, traits: [:video_notification_viewed]
  end
end
