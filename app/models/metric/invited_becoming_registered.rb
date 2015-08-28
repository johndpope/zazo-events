class Metric::InvitedBecomingRegistered < Metric::Base
  def self.type
    :rate_line_chart
  end

  def generate
    Event.connection.select_all(query).each_with_object({}) do |row, memo|
      memo[row['week']] = row['percentage'].to_f
    end
  end

  protected

  def query
    <<-SQL
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
      ), count_by_invited AS (
        SELECT
          becoming_invited week,
          COUNT(invitee) count
        FROM truncated
        GROUP BY becoming_invited
      ), count_by_registered AS (
        SELECT
          becoming_registered week,
          COUNT(invitee) count
        FROM truncated
        WHERE becoming_registered NOTNULL
        GROUP BY becoming_registered
      ) SELECT
          count_by_invited.week,
          ROUND(count_by_registered.count::NUMERIC /
                NULLIF(count_by_invited.count, 0)::NUMERIC * 100, 2) percentage
        FROM count_by_invited
          JOIN count_by_registered
            ON count_by_registered.week = count_by_invited.week
        ORDER BY week
    SQL
  end
end
