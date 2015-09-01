class Metric::ActiveUsers < Metric::Base
  include Metric::GroupableByTimeFrame

  def generate
    results.each_with_object({}) do |row, memo|
      memo[row['period']] = row['count']
    end
  end

  private

  def results
    run_raw_query <<-SQL
      WITH viewed AS (
        SELECT
          triggered_at,
          data->>'receiver_id' user_mkey
        FROM events
        WHERE name = ARRAY['video', 'kvstore', 'viewed']::VARCHAR[]
      ), uploaded AS (
        SELECT
          triggered_at,
          data->>'sender_id' user_mkey
        FROM events
        WHERE name = ARRAY['video', 's3', 'uploaded']::VARCHAR[]
      ), merged AS (
        SELECT *
        FROM viewed
        UNION ALL (SELECT * FROM uploaded)
      ) SELECT
          DATE_TRUNC('#{group_by}', triggered_at) period,
          COUNT(DISTINCT user_mkey)
        FROM merged
        GROUP BY DATE_TRUNC('#{group_by}', triggered_at)
        ORDER BY period
    SQL
  end
end
