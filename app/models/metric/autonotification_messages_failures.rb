class Metric::AutonotificationMessagesFailures < Metric::Base
  def self.type
    :autonotification_messages_failures
  end

  def generate
    query
  end

  protected

  def query
    run_raw_query <<-SQL
      WITH non_undefined_s3_events AS (
        SELECT
          data->>'client_version' client_version,
          data->>'client_platform' client_platform,
          target_id,
          data->>'sender_id' sender_id,
          data->>'receiver_id' receiver_id,
          MAX(triggered_at) triggered_at
        FROM events
        WHERE
          name = '{video,s3,uploaded}' AND
          data->>'client_version' != 'undefined' AND data->>'client_platform' != 'undefined'
        GROUP BY client_version, client_platform, target_id, sender_id, receiver_id
      ), kvstore_received_events AS (
        SELECT
          target_id,
          data->>'receiver_platform' receiver_platform,
          MAX(triggered_at) triggered_at
        FROM events
        WHERE name = '{video,kvstore,received}'
        GROUP BY target_id, receiver_platform
      ), notification_received_events AS (
        SELECT
          target_id,
          data->>'receiver_platform' receiver_platform,
          MAX(triggered_at) triggered_at
        FROM events
        WHERE name = '{video,notification,received}'
        GROUP BY target_id, receiver_platform
      ), autonotification_events AS (
        SELECT
          non_undefined_s3_events.target_id,
          non_undefined_s3_events.client_version,
          non_undefined_s3_events.client_platform,
          kvstore_received_events.target_id kvstore_received_target_id,
          notification_received_events.target_id notification_received_target_id,
          kvstore_received_events.receiver_platform kvstore_received_receiver_platform,
          notification_received_events.receiver_platform notification_received_receiver_platform
        FROM non_undefined_s3_events
          LEFT JOIN kvstore_received_events
            ON kvstore_received_events.target_id = non_undefined_s3_events.target_id
          LEFT JOIN notification_received_events
            ON notification_received_events.target_id = non_undefined_s3_events.target_id
        WHERE
          non_undefined_s3_events.client_platform = 'android' AND
          non_undefined_s3_events.client_version::INTEGER >= 112
      ) SELECT
          client_platform from_platform,
          COALESCE(kvstore_received_receiver_platform, notification_received_receiver_platform, 'unknown') to_platform,
          COUNT(target_id) uploaded,
          COUNT(notification_received_target_id) notification_received,
          COUNT(kvstore_received_receiver_platform) kvstore_received
        FROM autonotification_events
        GROUP BY client_platform, kvstore_received_receiver_platform, notification_received_receiver_platform
    SQL
  end
end
