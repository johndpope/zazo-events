class Metric::MessagesSent < Metric::Base
  include Metric::GroupableByTimeFrame

  def generate
    Event.video_s3_uploaded.send(:"group_by_#{group_by}", :triggered_at).count
  end
end
