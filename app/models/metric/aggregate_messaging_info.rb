class Metric::AggregateMessagingInfo < Metric::Base
  attr_accessor :user_id, :friend_id
  after_initialize :set_attributes
  validates :user_id, presence: true

  def generate
     %i(outgoing incoming).reduce({}) do |result, direction|
       scope = find_scope(direction)
       total_sent = reduce(scope.by_name(%w(video s3 uploaded)))
       total_received = reduce(scope.name_overlap(%w(downloaded viewed)))
       result[direction] ||= {}
       result[direction][:total_sent] = total_sent
       result[direction][:total_received] = total_received
       result[direction][:undelivered_percent] = total_sent.nonzero? && (total_sent - total_received) * 100.0 / total_sent
       result
     end
  end

  protected

  def find_scope(direction)
    scopes = [:with_sender, :with_receiver]
    scopes.reverse! if direction == :incoming
    scope = Event.send("#{scopes.first}", user_id)
    scope = scope.send("#{scopes.last}", friend_id) if friend_id.present?
    scope
  end

  def reduce(scope)
    scope.distinct("data->>'video_filename'").count("data->>'video_filename'")
  end

  def set_attributes
    @user_id = attributes['user_id']
    @friend_id = attributes['friend_id']
  end
end
