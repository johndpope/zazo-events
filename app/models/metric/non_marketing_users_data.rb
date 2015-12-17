class Metric::NonMarketingUsersData < Metric::Base
  FAR_IN_PAST_DATE   = 10.years.ago.to_time
  IN_FAR_FUTURE_DATE = 10.years.from_now.to_time

  after_initialize :set_attributes
  attr_reader :start_date, :end_date

  def self.type
    :non_marketing_users_data
  end

  def generate
    run_raw_query(query)
  end

  private

  def set_attributes
    @start_date = (Time.parse attributes['start_date'] rescue FAR_IN_PAST_DATE)
    @end_date   = (Time.parse attributes['end_date']   rescue IN_FAR_FUTURE_DATE)
  end

  def query
    <<-SQL
      WITH invited AS (
        SELECT
          initiator_id invitee,
          triggered_at
        FROM events
        WHERE name @> ARRAY['user', 'invited']::VARCHAR[] AND
              triggered_at > '#{start_date}'
      ), invites AS (
        SELECT
          initiator_id inviter,
          target_id invitee,
          invited.triggered_at invited_at
        FROM events
          INNER JOIN invited ON events.target_id = invited.invitee
        WHERE
          name @> ARRAY['user', 'invitation_sent']::VARCHAR[] AND
          EXTRACT(EPOCH FROM events.triggered_at - invited.triggered_at) < 1
        GROUP BY inviter, target_id, invited.triggered_at
      ), invites_count_date_limited AS (
        SELECT
          inviter,
          COUNT(DISTINCT invitee) invites_sent
        FROM invites
        WHERE invited_at < '#{end_date}'
        GROUP BY inviter
      ), invites_count_not_limited AS (
        SELECT
          inviter,
          COUNT(DISTINCT invitee) invites_sent
        FROM invites
        GROUP BY inviter
      ), non_marketing_invitations AS (
        SELECT
          invited.invitee inviter,
          COALESCE(invites_count_not_limited.invites_sent, 0) not_limited_invites_sent,
          COALESCE(invites_count_date_limited.invites_sent, 0) date_limited_invites_sent
        FROM invited
          LEFT OUTER JOIN invites_count_not_limited  ON invites_count_not_limited.inviter = invited.invitee
          LEFT OUTER JOIN invites_count_date_limited ON invites_count_date_limited.inviter = invited.invitee
      ), verified AS (
        SELECT
          events.initiator_id initiator,
          MIN(events.triggered_at) becoming_verified
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'verified']::VARCHAR[]
        GROUP BY initiator_id
      ), registered AS (
        SELECT
          events.initiator_id initiator,
          MIN(events.triggered_at) becoming_registered
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'registered']::VARCHAR[]
        GROUP BY initiator_id
      ), app_link_clicks_date_limited AS (
        SELECT
          data->>'connection_creator_mkey' inviter,
          COUNT(DISTINCT data->>'connection_target_mkey') link_clicks
        FROM events
        WHERE name = '{user,app_link_clicked}' AND
              triggered_at > '#{start_date}' AND triggered_at < '#{end_date}'
        GROUP BY inviter
      ), app_link_clicks_not_limited AS (
        SELECT
          data->>'connection_creator_mkey' inviter,
          COUNT(DISTINCT data->>'connection_target_mkey') link_clicks
        FROM events
        WHERE name = '{user,app_link_clicked}' AND
              triggered_at > '#{start_date}'
        GROUP BY inviter
      ) SELECT
          non_marketing_invitations.inviter,
          becoming_registered,
          becoming_verified,
          not_limited_invites_sent,
          date_limited_invites_sent,
          COALESCE(app_link_clicks_not_limited.link_clicks, 0) app_link_clicks_not_limited,
          COALESCE(app_link_clicks_date_limited.link_clicks, 0) app_link_clicks_date_limited
        FROM non_marketing_invitations
          LEFT OUTER JOIN verified ON non_marketing_invitations.inviter = verified.initiator
          LEFT OUTER JOIN registered ON non_marketing_invitations.inviter = registered.initiator
          LEFT OUTER JOIN app_link_clicks_not_limited
            ON non_marketing_invitations.inviter = app_link_clicks_not_limited.inviter
          LEFT OUTER JOIN app_link_clicks_date_limited
            ON non_marketing_invitations.inviter = app_link_clicks_date_limited.inviter
    SQL
  end

  def leagcy_query
    <<-SQL
      WITH invited AS (
        SELECT
          initiator_id invitee,
          triggered_at
        FROM events
        WHERE name @> ARRAY['user', 'invited']::VARCHAR[] AND
              triggered_at > '#{start_date}' AND
              triggered_at < '#{end_date}'
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
          events.initiator_id initiator,
          MIN(events.triggered_at) becoming_verified
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'verified']::VARCHAR[]
        GROUP BY initiator_id
      ), registered AS (
        SELECT
          DISTINCT events.initiator_id initiator
        FROM events
          INNER JOIN invited ON events.initiator_id = invited.invitee
        WHERE name @> ARRAY['user', 'registered']::VARCHAR[]
      ), app_link_clicks AS (
        SELECT
          data->>'connection_creator_mkey' inviter,
          COUNT(DISTINCT data->>'connection_target_mkey') link_clicks
        FROM events
        WHERE name = '{user,app_link_clicked}' AND
              triggered_at > '#{start_date}' AND
              triggered_at < '#{end_date}'
        GROUP BY inviter
      ) SELECT
          non_marketing_invitations.inviter,
          becoming_verified,
          invites_sent,
          COALESCE(link_clicks, 0) link_clicks,
          CASE WHEN verified.initiator ISNULL THEN FALSE ELSE TRUE END is_verified,
          CASE WHEN registered.initiator ISNULL THEN FALSE ELSE TRUE END is_registered
        FROM non_marketing_invitations
          LEFT OUTER JOIN verified ON non_marketing_invitations.inviter = verified.initiator
          LEFT OUTER JOIN registered ON non_marketing_invitations.inviter = registered.initiator
          LEFT OUTER JOIN app_link_clicks ON non_marketing_invitations.inviter = app_link_clicks.inviter
    SQL
  end
end
