class Metric::InvitationFunnel::AverageInvitationsCount < Metric::InvitationFunnel::Base
  def generate
    query <<-SQL
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
          DISTINCT events.initiator_id initiator,
          MIN(events.triggered_at) becoming_verified
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'verified']::VARCHAR[] AND
              events.triggered_at > '#{start_date}' AND
              events.triggered_at < '#{end_date}'
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
          EXTRACT(EPOCH FROM events.triggered_at - invited.triggered_at) < 1 AND
          events.triggered_at > '#{start_date}' AND
          events.triggered_at < '#{end_date}'
      ), group_by_weeks AS (
        SELECT
          EXTRACT(days FROM (inviters.invite_sent - verified.becoming_verified) / 7) + 1 week,
          verified.initiator
        FROM verified
          INNER JOIN inviters ON verified.initiator = inviters.inviter
      ), count_by_six_weeks AS (
        SELECT
          number::TEXT week,
          initiator::TEXT,
          COUNT(initiator) invitations_count
        FROM group_by_weeks
          RIGHT OUTER JOIN generate_series(1, 6) number ON number = group_by_weeks.week
        GROUP BY number, initiator
      ), count_after_six_weeks AS (
        SELECT
          'after 6 weeks'::TEXT week,
          initiator,
          COUNT(*) invitations_count
        FROM group_by_weeks
        WHERE week > 6
        GROUP BY initiator
      ), count_by_weeks AS (
        SELECT *
        FROM count_by_six_weeks
        UNION
        SELECT *
        FROM count_after_six_weeks
      ) (SELECT
            week week_after_verified,
            ROUND(SUM(invitations_count) /
                  COALESCE(NULLIF((SELECT COUNT(DISTINCT initiator) FROM count_by_weeks), 0), 1)
            , 3) avg_invitations_count
          FROM count_by_weeks
          GROUP BY week
          ORDER BY week
        ) UNION (
          SELECT
            'total'::TEXT week_after_verified,
            ROUND(COUNT(*)::NUMERIC /
                  COALESCE(NULLIF((SELECT COUNT(DISTINCT initiator) FROM count_by_weeks), 0), 1)
            , 3) avg_invitations_count
          FROM group_by_weeks
        ) ORDER BY week_after_verified
    SQL
  end
end
