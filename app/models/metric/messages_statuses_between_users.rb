class Metric::MessagesStatusesBetweenUsers < Metric::Base
  attr_accessor :user_id, :friend_ids
  after_initialize :set_attributes
  validates :user_id, :friend_ids, presence: true

  def generate
    data  = query
    total = empty_user_data
    results = data.each_with_object({}) do |row, memo|
      memo[row['friend']] ||= empty_user_data
      memo[row['friend']][row['direction'].to_sym] = {
        sent:       row['sent'].to_i,
        incomplete: row['incompleted'].to_i,
        unviewed:   row['unviewed'].to_i
      }
      total[row['direction'].to_sym][:sent] += row['sent'].to_i
      total[row['direction'].to_sym][:incomplete] += row['incompleted'].to_i
      total[row['direction'].to_sym][:unviewed] += row['unviewed'].to_i
    end
    friend_ids.each { |u| results[u] = empty_user_data unless results.key? u }
    results[:total] = total
    results
  end

  protected

  def empty_user_data
    direction_data = {
      sent: 0,
      incomplete: 0,
      unviewed: 0
    }
    { outgoing: direction_data.deep_dup,
      incoming: direction_data.deep_dup }
  end

  def query
    sql = <<-SQL
      WITH outgoing AS (
      SELECT
        DISTINCT name status,
        target_id message,
        data->>'receiver_id' friend,
        'outgoing' direction
      FROM events
      WHERE name && ARRAY['video']::VARCHAR[] AND
            data->>'sender_id' = ? AND
            data->>'receiver_id' IN (?)
    ), incoming AS (
      SELECT
        DISTINCT name status,
        target_id message,
        initiator_id friend,
        'incoming' direction
      FROM events
      WHERE name && ARRAY['video']::VARCHAR[] AND
            data->>'sender_id' IN (?) AND
            data->>'receiver_id' = ?
    ), total AS (
      SELECT *
      FROM outgoing
      UNION SELECT * FROM incoming
    ), incompleted AS (
      SELECT
        message,
        TRUE is_incompleted
      FROM total
      GROUP BY message
      HAVING COUNT(status) < 7
    ), viewed AS (
      SELECT
        DISTINCT message
      FROM total
      WHERE status @> ARRAY['video','kvstore','viewed']::VARCHAR[] OR
            status @> ARRAY['video','notification','viewed']::VARCHAR []
    ), unviewed AS (
      SELECT
        DISTINCT total.message,
        TRUE is_unviewed
      FROM total
      LEFT OUTER JOIN viewed ON total.message = viewed.message
      WHERE viewed.message ISNULL
    ), total_extended AS (
      SELECT
        DISTINCT total.message,
        friend, direction,
        incompleted.is_incompleted,
        unviewed.is_unviewed
      FROM total
        LEFT OUTER JOIN incompleted ON total.message = incompleted.message
        LEFT OUTER JOIN unviewed ON total.message = unviewed.message
      WHERE friend NOTNULL
    ) SELECT
        friend, direction,
        COUNT(message) sent,
        COUNT(is_incompleted) incompleted,
        COUNT(is_unviewed) unviewed
      FROM total_extended
      GROUP BY friend, direction
      ORDER BY direction DESC
    SQL
    sql = Event.send :sanitize_sql_array,
                     [sql, user_id, friend_ids, friend_ids, user_id]
    Event.connection.select_all sql
  end

  def set_attributes
    @user_id = attributes['user_id']
    @friend_ids = Array.wrap(attributes['friend_ids'])
  end
end
