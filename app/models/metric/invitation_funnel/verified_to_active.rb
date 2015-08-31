class Metric::InvitationFunnel::VerifiedToActive < Metric::InvitationFunnel::Base
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
      ), verified AS (
        SELECT
          events.initiator_id initiator,
          MIN(events.triggered_at) becoming_verified
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'verified']::VARCHAR[] AND
              events.triggered_at > '#{start_date}' AND
              events.triggered_at < '#{end_date}'
        GROUP BY initiator_id
      ), active AS (
        SELECT
          events.data->>'sender_id' initiator,
          MIN(events.triggered_at) becoming_active
        FROM events
        WHERE name @> ARRAY['video', 's3', 'uploaded']::VARCHAR[] AND
              events.triggered_at > '#{start_date}' AND
              events.triggered_at < '#{end_date}'
        GROUP BY data->>'sender_id'
      ) SELECT
          (SELECT COUNT(*) FROM verified) total_verified,
          COUNT(*) verified_that_active,
          ROUND(AVG(EXTRACT(EPOCH FROM becoming_active -
                            becoming_verified) / 60)::numeric) avg_delay_in_minutes
        FROM active
          INNER JOIN verified ON verified.initiator = active.initiator
    SQL
    default_if_key_nil data, :avg_delay_in_minutes
  end

  def default_data
    { total_verified: 0,
      verified_that_active: 0,
      avg_delay_in_minutes: 0 }
  end
end
