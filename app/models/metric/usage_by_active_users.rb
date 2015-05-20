class Metric::UsageByActiveUsers < Metric::Base
  def generate
    total_messages.reduce({}) do |memo, (time_frame, messages_count)|
      users_count = users_sent_message_reduced[time_frame].size
      memo[time_frame] = messages_count.to_f / users_count.to_f
      memo
    end
  end

  private

  def total_messages
    @total_messages ||= messages_sent_scope.count
  end

  def users_sent_message
    @users_sent_message ||= messages_sent_scope.group("data->>'sender_id'").count
  end

  def users_sent_message_reduced
    @users_sent_message_reduced ||= reduce_by_users(users_sent_message)
  end

  def messages_sent_scope
    Event.by_name(%w(video s3 uploaded)).send(:"group_by_#{group_by}", :triggered_at)
  end

  def reduce_by_users(data)
    data.reduce({}) do |memo, (key, value)|
      next memo if value.zero?
      time_frame, user_id = key
      memo[time_frame] ||= Set.new
      memo[time_frame] << user_id
      memo
    end
  end
end
