class Metric::ActiveUsers < Metric::Base
  def generate
    zip(reduce(video_uploaded), reduce(video_viewed))
  end

  private

  def video_uploaded
    @video_uploaded ||= Event.by_name(%w(video s3 uploaded)).group("data->>'sender_id'").send(:"group_by_#{@group_by}", :triggered_at).count
  end

  def video_viewed
    @video_viewed ||= Event.by_name(%w(video kvstore viewed)).group("data->>'sender_id'").send(:"group_by_#{@group_by}", :triggered_at).count
  end

  def reduce(data)
    data.reduce({}) do |memo, (key, value)|
      _, time_frame = key
      memo[time_frame] ||= 0
      memo[time_frame] += value
      memo
    end
  end

  def zip(first, second)
    result = {}
    first.zip(second) do |(time_frame, count_1), (_, count_2)|
      result[time_frame] = count_1.to_i + count_2.to_i
    end
    result
  end
end
