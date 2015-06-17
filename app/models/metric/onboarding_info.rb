class Metric::OnboardingInfo < Metric::Base
  STATES = %w(active invited registered verified)

  def generate
    data = results
    data.keys.each_with_object({}) do |key, memo|
      STATES.each do |state|
        memo[state] ||= {}
        memo[state][key] = (data[key][state] || 0).to_i
      end
    end
  end

  protected

  def results
    results = by_states.each_with_object({}) do |value, memo|
      memo["#{value['period']} UTC"] ||= {}
      memo["#{value['period']} UTC"][value['name']] = value['count']
    end
    by_active.each do |value|
      results["#{value['period']} UTC"] ||= {}
      results["#{value['period']} UTC"]['active'] = value['count']
    end
    results.sort.to_h
  end

  def by_states
    sql = <<-SQL
      SELECT
        name[2],
        DATE_TRUNC('day', triggered_at) period,
        COUNT(DISTINCT initiator_id)
      FROM events
      WHERE name && ARRAY['invited', 'registered', 'verified']::VARCHAR[]
      GROUP BY period, name
    SQL
    Event.connection.select_all sql
  end

  def by_active
    sql = <<-SQL
      WITH first_messages AS (
        SELECT
          data->>'sender_id' sender,
          MIN(triggered_at) triggered_at
        FROM events
        WHERE
          name @> ARRAY['video', 's3', 'uploaded']::VARCHAR[]
        GROUP BY sender
      )
      SELECT
        DATE_TRUNC('day', triggered_at) as period,
        COUNT(DISTINCT sender)
      FROM first_messages
      GROUP BY period
    SQL
    Event.connection.select_all sql
  end
end
