class Metric::AggregateMessagingInfo < Metric::Base
  SCOPE_MAPPING = { outgoing: :with_sender, incoming: :with_receiver }

  attr_accessor :user_id
  after_initialize :set_user_id
  validates :user_id, presence: true

  def generate
     %i(outgoing incoming).reduce({}) do |result, scope_name|
       scope = Event.send(SCOPE_MAPPING[scope_name], user_id)
       total_sent = reduce(scope.by_name(%w(video s3 uploaded)))
       total_received = reduce(scope.by_name(%w(video kvstore downloaded)))
       result[scope_name] ||= {}
       result[scope_name][:total_sent] = total_sent
       result[scope_name][:total_received] = total_received
       result[scope_name][:undelivered_percent] = total_sent.nonzero? && (total_sent - total_received) * 100.0 / total_sent
       result
     end
  end

  protected

  def reduce(scope)
    scope.distinct("data->>'video_filename'").count
  end

  def set_user_id
    @user_id = attributes['user_id']
  end
end
