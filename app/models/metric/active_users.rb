class Metric::ActiveUsers < Metric::Base
  def generate
    zip(reduce(video_uploaded), reduce(video_viewed))
  end

  private

  def video_uploaded
    @video_uploaded ||= Event.by_name(%w(video s3 uploaded)).group("data->>'sender_id'").send(:"group_by_#{@group_by}", :triggered_at).count
  end

  def video_viewed
    @video_viewed ||= Event.by_name(%w(video kvstore viewed)).group("data->>'receiver_id'").send(:"group_by_#{@group_by}", :triggered_at).count
  end

  def reduce(data)
    data.reduce({}) do |memo, (key, value)|
      next memo if value.zero?
      user_id, time_frame = key
      memo[time_frame] ||= Set.new
      memo[time_frame] << user_id
      memo
    end
  end

  def zip(first, second)
    first.reduce({}) do |memo, (time_frame, user_ids)|
      memo[time_frame] = (user_ids + second[time_frame] || []).size
      memo
    end
  end
end
