class Metric::InvitationFunnel::InvitedToRegistered < Metric::InvitationFunnel::Base
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
          DISTINCT events.initiator_id initiator,
          MIN(events.triggered_at) becoming_registered
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'registered']::VARCHAR[] AND
              events.triggered_at > '#{start_date}' AND
              events.triggered_at < '#{end_date}'
        GROUP BY initiator_id
      ) SELECT
          (SELECT COUNT(*) FROM invited) total_invited,
          COUNT(*) invited_that_register,
          ROUND(AVG(EXTRACT(EPOCH FROM
            registered.becoming_registered -
            invited.triggered_at) / 3600)::numeric) avg_delay_in_hours
        FROM registered
          INNER JOIN invited ON registered.initiator = invited.invitee
    SQL
    default_if_key_nil data, :avg_delay_in_hours
  end

  def default_data
    { total_invited: 0,
      invited_that_register: 0,
      avg_delay_in_hours: 0 }
  end
end
