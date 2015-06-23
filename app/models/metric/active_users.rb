class Metric::ActiveUsers < Metric::Base
  include Metric::GroupableByTimeFrame

  def generate
    zip(reduce_by_users(video_uploaded), reduce_by_users(video_viewed))
  end

  private

  def video_uploaded
    @video_uploaded ||= common_scope.video_s3_uploaded.group("data->>'sender_id'").count("data->>'sender_id'")
  end

  def video_viewed
    @video_viewed ||= common_scope.by_name(%w(video kvstore viewed)).group("data->>'receiver_id'").count("data->>'receiver_id'")
  end

  def common_scope
    Event.send(:"group_by_#{group_by}", :triggered_at)
  end

  def zip(first, second)
    first.each_with_object({}) do |(time_frame, user_ids), memo|
      total = Set.new
      total += Set.new(user_ids) if user_ids.present?
      total += Set.new(second[time_frame]) if second[time_frame].present?
      memo[time_frame] = total.size
    end
  end
end
