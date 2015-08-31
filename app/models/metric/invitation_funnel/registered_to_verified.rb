class Metric::InvitationFunnel::RegisteredToVerified < Metric::InvitationFunnel::Base
  def generate
    data = query_first <<-SQL
      WITH invited AS (
        SELECT
          initiator_id invitee,
          triggered_at
        FROM events
        WHERE name @> ARRAY['user', 'invited']::VARCHAR[] AND
              events.triggered_at > '#{start_date}' AND
              events.triggered_at < '#{end_date}'
      ), registered AS (
        SELECT
          DISTINCT
          events.initiator_id initiator,
          MIN(events.triggered_at) becoming_registered
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'registered']::VARCHAR[] AND
              events.triggered_at > '#{start_date}' AND
              events.triggered_at < '#{end_date}'
        GROUP BY initiator_id
      ), verified AS (
        SELECT
          initiator_id initiator,
          becoming_registered,
          MIN(events.triggered_at) becoming_verified
        FROM events
          INNER JOIN registered ON events.initiator_id = registered.initiator
        WHERE name @> ARRAY['user', 'verified']::VARCHAR[] AND
              events.triggered_at > '#{start_date}' AND
              events.triggered_at < '#{end_date}'
        GROUP BY initiator_id, becoming_registered
      ) SELECT
          (SELECT COUNT(*) FROM registered) total_registered,
          (SELECT COUNT(*) FROM verified) registered_that_verify,
          ROUND(AVG(EXTRACT(EPOCH FROM
            becoming_verified -
            becoming_registered) / 60)::numeric) avg_delay_in_minutes
      FROM verified
    SQL
    default_if_key_nil data, :avg_delay_in_minutes
  end

  def default_data
    { total_registered: 0,
      registered_that_verify: 0,
      avg_delay_in_minutes: 0 }
  end
end
