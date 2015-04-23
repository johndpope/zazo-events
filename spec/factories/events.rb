FactoryGirl.define do
  factory :event do
    name 'video:sent'
    triggered_at '2015-04-22T18:01:20.663Z'
    triggered_by 'aws:s3'
    initiator 'user'
    initiator_id 'RxDrzAIuF9mFw7Xx9NSM'
    target 'user'
    target_id '6pqpuUZFp1zCXLykfTIx'
  end
end
