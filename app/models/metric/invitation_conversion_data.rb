class Metric::InvitationConversionData < Metric::Base
  FAR_IN_PAST_DATE   = 10.years.ago.to_time
  IN_FAR_FUTURE_DATE = 10.years.from_now.to_time

  after_initialize :set_attributes
  attr_reader :start_date, :end_date

  def self.type
    :invitation_conversion_data
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
          initiator_id,
          MIN(triggered_at) invited_at
        FROM events
        WHERE name = '{user,invited}'
        GROUP BY initiator_id
      ), registered AS (
        SELECT
          initiator_id,
          MIN(events.triggered_at) registered_at
        FROM events
        WHERE name = '{user,registered}'
        GROUP BY initiator_id
      ), app_link_clicks_date_limited AS (
        SELECT
          data->>'connection_target_mkey' target,
          COUNT(*) clicks
        FROM events
        WHERE name = '{user,app_link_clicked}' AND
              triggered_at > '#{start_date}' AND
              triggered_at < '#{end_date}'
        GROUP BY data->>'connection_target_mkey'
      ), app_link_clicks_not_limited AS (
        SELECT
          data->>'connection_target_mkey' target,
          COUNT(*) clicks
        FROM events
        WHERE name = '{user,app_link_clicked}'
        GROUP BY data->>'connection_target_mkey'
      ) SELECT
          invited.initiator_id initiator,
          invited_at,
          registered.registered_at,
          app_link_clicks_not_limited.clicks clicks_not_limited,
          app_link_clicks_date_limited.clicks clicks_date_limited
        FROM invited
          LEFT OUTER JOIN registered
            ON invited.initiator_id = registered.initiator_id
          LEFT OUTER JOIN app_link_clicks_not_limited
            ON invited.initiator_id = app_link_clicks_not_limited.target
          LEFT OUTER JOIN app_link_clicks_date_limited
            ON invited.initiator_id = app_link_clicks_date_limited.target
    SQL
  end
end
