class Metric::MessagesCountByPeriod < Metric::Base
  include Metric::GroupableByTimeFrame
  after_initialize :set_attributes

  attr_accessor :users_ids, :group_by, :since
  validates :users_ids, presence: true

  def generate
    results(%w(video s3 uploaded)).each_with_object({}) do |value, memo|
      memo[value['sender']] ||= {}
      memo[value['sender']]["#{value['period']} UTC"] = value['count'].to_i
    end
  end

  protected

  def results(events)
    sql = <<-SQL
      SELECT
        data->>'sender_id' as sender,
        DATE_TRUNC(?, triggered_at) as period,
        COUNT(DISTINCT data->>'video_filename')
      FROM events
      WHERE data->>'sender_id' IN (?)
      AND name = ARRAY[?]::varchar[]
      GROUP BY period, sender
      ORDER BY sender, period
    SQL
    sql = Event.send :sanitize_sql_array,
                     [sql, group_by, users_ids, events]
    Event.connection.select_all sql
  end

  def set_attributes
    @users_ids = Array(attributes['users_ids'])
    @since     = attributes['since']
  end
end
