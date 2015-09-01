class Metric::UsageByActiveUsers < Metric::Base
  include Metric::GroupableByTimeFrame

  def generate
    results.each_with_object({}) do |row, memo|
      memo[row['period']] = row['average_count'].to_f
    end
  end

  private

  def results
    run_raw_query <<-SQL
      WITH usage AS (
        SELECT
          DATE_TRUNC('#{group_by}', triggered_at) period,
          data->>'sender_id' user_mkey,
          COUNT(DISTINCT data->>'video_filename') count
        FROM events
        WHERE name = ARRAY['video', 's3', 'uploaded']::VARCHAR[]
        GROUP BY period, user_mkey
      ) SELECT
          period,
          AVG(count) average_count
        FROM usage
        GROUP BY period
        ORDER BY period
    SQL
  end
end
