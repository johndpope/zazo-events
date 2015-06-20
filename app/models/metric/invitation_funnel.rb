class Metric::InvitationFunnel < Metric::Base
  def generate
    {
      active_sent_invitations: active_sent_invitations,
      average_invitations_count: average_invitations_count
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

  def average_invitations_count
    sql = <<-SQL
      WITH invited AS (
        SELECT
          initiator_id invitee,
          triggered_at
        FROM events
        WHERE name @> ARRAY['user', 'invited']::VARCHAR[]
      ), verified AS (
        SELECT
          DISTINCT events.initiator_id initiator,
          MIN(events.triggered_at) becoming_verified
        FROM events
        INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'verified']::VARCHAR[]
        GROUP BY initiator_id
      ), inviters AS (
        SELECT
          events.initiator_id inviter,
          events.target_id invitee,
          events.triggered_at invite_sent
        FROM events
          INNER JOIN invited ON events.target_id = invited.invitee
        WHERE
          name @> ARRAY['user', 'invitation_sent']::VARCHAR[] AND
          EXTRACT(EPOCH FROM events.triggered_at - invited.triggered_at) < 1
      ), group_by_weeks AS (
        SELECT
          extract(days from (inviters.invite_sent - verified.becoming_verified) / 7) + 1 week,
          verified.initiator
        FROM verified INNER JOIN inviters ON verified.initiator = inviters.inviter
      ), count_by_weeks AS (
        SELECT
          week,
          initiator,
          COUNT(initiator) invitations_count
        FROM group_by_weeks INNER JOIN generate_series(1, 6) number ON number = group_by_weeks.week
        GROUP BY week, initiator
      ) SELECT
          week week_after_verified,
          SUM(invitations_count) / (SELECT COUNT(*) FROM count_by_weeks) avg_invitations_count
        FROM count_by_weeks
        GROUP BY week
    SQL
    Event.connection.select_all(sql)[0]
  end
end
