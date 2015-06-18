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
      raw_params do
        {
          'eventVersion' => '2.0',
          'eventSource' => 'aws:s3',
          'awsRegion' => 'us-west-1',
          'eventTime' => '2015-04-22T18:01:20.663Z',
          'eventName' => 'ObjectCreated:Put',
          'userIdentity' => {
            'principalId' => 'AWS:AIDAIUFT72XFHDTJOMRJW'
          },
          'requestParameters' => {
            'sourceIPAddress' => '49.204.248.238'
          },
          'responseElements' => {
            'x-amz-request-id' => 'EEC1C1CCB42A1720',
            'x-amz-id-2' => '/6QHbf9n3yNRrAuCz6kRkeAHTIl7fxr3ZOrnpMw6xqdgTwEK1RVU7D4R68OsFgjH0fB1LaFKaSU='
          },
          's3' => {
            's3SchemaVersion' => '1.0',
            'configurationId' => 'zazo-videos-to-sqs',
            'bucket' => {
              'name' => 'videos.zazo.com',
              'ownerIdentity' => {
                'principalId' => 'A2MSYRMSE88G92'
              },
              'arn' => 'arn:aws:s3:::videos.zazo.com'
            },
            'object' => {
              'key' => data['video_filename'],
              'size' => 94_555,
              'eTag' => 'd99d0f13a57d938a1e55b5030feb992e'
            }
          }
        }
      end
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
