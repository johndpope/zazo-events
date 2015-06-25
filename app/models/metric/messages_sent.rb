class Metric::MessagesSent < Metric::Base
  include Metric::GroupableByTimeFrame

  def generate
    Event.video_s3_uploaded
      .distinct
      .select(:triggered_at, "data->>'video_filename'")
      .send(:"group_by_#{group_by}", :triggered_at)
      .count("data->>'video_filename'")
  end
end
