class Metric::MessagesSent < Metric::Base
  def generate
    Event.by_name(%w(video s3 uploaded)).send(:"group_by_#{@group_by}", :triggered_at).count
  end
end