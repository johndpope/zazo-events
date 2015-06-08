class Metric::MessagesCountByPeriod < Metric::Base
  include Metric::GroupableByTimeFrame
  after_initialize :set_attributes

  attr_accessor :user_id, :group_by, :since

  validates :user_id, presence: true
  # todo: since date validation

  def generate
    scope = Event.with_sender, user_id
    reduce(scope.by_name(%w(video s3 uploaded))).sort.to_h
  end

protected

  def reduce(scope)
    scope = scope.since since if since.present?
    scope.group("DATE_TRUNC('#{group_by}', triggered_at)")
         .distinct("data->>'video_filename'")
         .count("data->>'video_filename'")
  end

  def set_attributes
    @user_id   = attributes['user_id']
    @since     = attributes['since']
  end
end
