class Metric::ActiveDaysByActiveFriends < Metric::Base
  def self.type
    :active_days_by_active_friends
  end

  def generate
    run_raw_query(query)
  end

  private

  def query
    <<-SQL
      WITH video_sent AS (
        SELECT DISTINCT
          data->>'sender_id' sender_id,
          data->>'receiver_id' receiver_id,
          MIN(date_trunc('day', triggered_at)) triggered_at
        FROM events
        WHERE name = '{video,kvstore,received}'
        GROUP BY target_id, sender_id, receiver_id
      ), video_received AS (
        SELECT DISTINCT
          data->>'sender_id' sender_id,
          data->>'receiver_id' receiver_id,
          MIN(date_trunc('day', triggered_at)) triggered_at
        FROM events
        WHERE name = '{video,notification,received}'
        GROUP BY target_id, sender_id, receiver_id
      ), activity AS (
        SELECT *
        FROM video_sent
        UNION SELECT *
              FROM video_received
      ), activity_by_user AS (
        SELECT DISTINCT
          sender_id,
          triggered_at
        FROM activity
      ), active_friends AS (
        SELECT
          sender_id "user",
          COUNT(DISTINCT receiver_id) "count"
        FROM activity
        GROUP BY sender_id
      ), registered AS (
        SELECT
          initiator_id,
          MIN(triggered_at) registered_at
        FROM events
        WHERE name = '{user,registered}'
        GROUP BY initiator_id
      ), prepared_data AS (
        SELECT
          initiator_id,
          ROUND(COUNT(activity_by_user.sender_id) :: NUMERIC / COUNT(day) :: NUMERIC, 4) percent_active_days,
          COALESCE(active_friends.count, 0) active_friends
        FROM registered
          CROSS JOIN generate_series(registered_at, now(), '1 day' :: INTERVAL) day
          LEFT OUTER JOIN activity_by_user ON activity_by_user.sender_id = registered.initiator_id AND
                                              activity_by_user.triggered_at = date_trunc('day', day)
          LEFT OUTER JOIN active_friends ON registered.initiator_id = active_friends."user"
        GROUP BY registered.initiator_id, registered_at, active_friends.count
      ), activity_by_active_days AS (
        SELECT
          active_friends,
          AVG(percent_active_days) avg_percent_active_days
        FROM prepared_data
        GROUP BY active_friends
        ORDER BY active_friends
      ) SELECT
          active_friends::VARCHAR,
          avg_percent_active_days
        FROM activity_by_active_days
        WHERE active_friends > 0 AND active_friends < 8
        UNION
          SELECT
            '8 or more'::VARCHAR active_friends,
            AVG(avg_percent_active_days) avg_percent_active_days
          FROM activity_by_active_days
          WHERE active_friends >= 8
    SQL
  end
end
