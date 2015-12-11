class Metric::NonMarketingUsersData < Metric::Base
  def self.type
    :non_marketing_users_data
  end

  def generate
    run_raw_query(query)
  end

  private

  def query
    <<-SQL
      WITH invited AS (
        SELECT
          initiator_id invitee,
          triggered_at
        FROM events
        WHERE name @> ARRAY['user', 'invited']::VARCHAR[]
      ), inviters AS (
        SELECT
          events.initiator_id inviter,
          COUNT(events.target_id) invites_sent
        FROM events
          INNER JOIN invited ON events.target_id = invited.invitee
        WHERE
          name @> ARRAY['user', 'invitation_sent']::VARCHAR[] AND
          EXTRACT(EPOCH FROM events.triggered_at - invited.triggered_at) < 1
        GROUP BY inviter
      ), non_marketing_invitations AS (
        SELECT
          invited.invitee inviter,
          COALESCE(invites_sent, 0) invites_sent
        FROM invited
          LEFT OUTER JOIN inviters ON inviters.inviter = invited.invitee
      ), verified AS (
        SELECT
          DISTINCT events.initiator_id initiator
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'verified']::VARCHAR[]
      ), registered AS (
        SELECT
          DISTINCT events.initiator_id initiator
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'registered']::VARCHAR[]
      ) SELECT
          inviter,
          invites_sent,
          CASE WHEN verified.initiator ISNULL THEN FALSE ELSE TRUE END is_verified,
          CASE WHEN registered.initiator ISNULL THEN FALSE ELSE TRUE END is_registered
        FROM non_marketing_invitations
          LEFT OUTER JOIN verified ON non_marketing_invitations.inviter = verified.initiator
          LEFT OUTER JOIN registered ON non_marketing_invitations.inviter = registered.initiator
    SQL
  end
end
