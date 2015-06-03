class Metric::UsageByActiveUsers < Metric::Base
  include Metric::GroupableByTimeFrame

  def generate
    total_messages.each_with_object({}) do |(time_frame, messages_count), memo|
      users_count = users_sent_message_reduced[time_frame].try(:size) || 0
      next if users_count.zero?
      memo[time_frame] = messages_count.to_f / users_count.to_f
    end
  end

  private

  def total_messages
    @total_messages ||= messages_sent_scope.count
  end

  def users_sent_message
    @users_sent_message ||= messages_sent_scope.group("data->>'sender_id'").count("data->>'sender_id'")
  end

  def users_sent_message_reduced
    @users_sent_message_reduced ||= reduce_by_users(users_sent_message)
  end

  def messages_sent_scope
    Event.by_name(%w(video s3 uploaded)).send(:"group_by_#{group_by}", :triggered_at)
  end
end
