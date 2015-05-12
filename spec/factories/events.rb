FactoryGirl.define do
  factory :event do
    name %w(video s3 uploaded)
    triggered_at { DateTime.now }
    triggered_by 'aws:s3'
    initiator 'user'
    initiator_id 'RxDrzAIuF9mFw7Xx9NSM'
    target 'video'
    target_id 'RxDrzAIuF9mFw7Xx9NSM-6pqpuUZFp1zCXLykfTIx-98dba07c0113cc717d9fc5e5809bc998'
    message_id { Digest::UUID.uuid_v4 }
  end
end
