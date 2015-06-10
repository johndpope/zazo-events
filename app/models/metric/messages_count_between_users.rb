class Metric::MessagesCountBetweenUsers < Metric::Base
  after_initialize :set_attributes

  attr_accessor :user_id, :friends_ids

  validates :user_id, :friends_ids, presence: true

  def generate
    results %w(downloaded viewed)
  end

protected

  def results(events)
    sql = <<-SQL
      SELECT
        data->>'sender_id' as sender,
        data->>'receiver_id' as receiver,
        COUNT(DISTINCT data->>'video_filename')
      FROM events
      WHERE (
        data ->> 'sender_id'     = ? AND
        data ->> 'receiver_id' IN (?) OR
        data ->> 'sender_id'   IN (?) AND
        data ->> 'receiver_id'   = ?
      )
      AND name && ARRAY[?]::varchar[]
      GROUP BY receiver, sender
    SQL
    sql = Event.send :sanitize_sql_array,
                     [sql, user_id, friends_ids,
                      friends_ids, user_id, events]
    Event.connection.select_all sql
  end

  def set_attributes
    @user_id     = attributes['user_id']
    @friends_ids = attributes['friends_ids']
  end
end
