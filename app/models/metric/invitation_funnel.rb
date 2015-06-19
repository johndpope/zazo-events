class Metric::InvitationFunnel < Metric::Base
  def generate
    {
      active_sent_invitations: active_sent_invitations
    }
  end

  protected

  def active_sent_invitations
    sql = <<-SQL
      WITH active AS (
        SELECT
          DISTINCT data->>'sender_id' sender,
          MIN(triggered_at) becoming_active
        FROM events
        WHERE name @> ARRAY['video', 's3', 'uploaded']::VARCHAR[]
        GROUP BY sender
      ), invited AS (
        SELECT
          initiator_id target,
          triggered_at
        FROM events
        WHERE name @> ARRAY['user', 'invited']::VARCHAR[]
      ), inviters AS (
        SELECT
          DISTINCT events.initiator_id inviter,
          MIN(events.triggered_at) first_invitation
        FROM events
        INNER JOIN invited ON events.target_id = invited.target
        WHERE
          name @> ARRAY['user', 'invitation_sent']::VARCHAR[] AND
          EXTRACT(EPOCH FROM events.triggered_at - invited.triggered_at) < 1
        GROUP BY inviter
      ) SELECT
          (SELECT COUNT(*) FROM active) total_active,
          COUNT(*) active_sent_invitation,
          AVG(EXTRACT(EPOCH FROM
                inviters.first_invitation -
                active.becoming_active) / 3600) avg_in_hours
        FROM active
        INNER JOIN inviters ON active.sender = inviters.inviter
    SQL
    Event.connection.select_all(sql)[0]
  end
end
