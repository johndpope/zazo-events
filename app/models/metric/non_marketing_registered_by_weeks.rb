class Metric::NonMarketingRegisteredByWeeks < Metric::Base
  def self.type
    :simple_line_chart
  end

  def generate
    query.each_with_object({}) do |row, memo|
      memo[row['week']] = row['count'].to_i
    end
  end

  private

  def query
    run_raw_query <<-SQL
      WITH invited AS (
        SELECT
          initiator_id invitee,
          MAX(triggered_at) becoming_invited
        FROM events
        WHERE name @> ARRAY['user', 'invited']::VARCHAR[]
        GROUP BY initiator_id
      ), registered AS (
        SELECT
          DISTINCT events.initiator_id initiator,
          MIN(events.triggered_at) becoming_registered
        FROM events
          JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'registered']::VARCHAR[]
        GROUP BY initiator_id
      ), truncated AS (
        SELECT
          invitee,
          date_trunc('week', becoming_invited)    becoming_invited,
          date_trunc('week', becoming_registered) becoming_registered
        FROM invited
          LEFT JOIN registered ON invited.invitee = registered.initiator
      ) SELECT
          becoming_registered week,
          COUNT(invitee) count
        FROM truncated
        WHERE becoming_registered NOTNULL
        GROUP BY becoming_registered
        ORDER BY week
    SQL
  end
end
