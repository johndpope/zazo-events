class Metric::UploadDuplicationsData < Metric::Base
  after_initialize :set_attributes
  attr_reader :senders

  def self.type
    :upload_duplications_data
  end

  def generate
    run_raw_query(query)
  end

  private

  def set_attributes
    @senders = attributes['senders']
  end

  def query
    <<-SQL
      SELECT
        data->>'sender_id' sender_id,
        target_id,
        COUNT(*) count,
        MIN(triggered_at) first_triggered_at,
        MAX(triggered_at) last_triggered_at,
        data->>'client_platform' client_platform,
        data->>'client_version' client_version
      FROM events
      WHERE name = '{video,s3,uploaded}' AND #{restrictions} AND
            (raw_params->'s3'->'object'->>'size')::NUMERIC > 0
      GROUP BY sender_id, target_id, client_platform, client_version
      HAVING COUNT(*) > 1
      ORDER BY last_triggered_at DESC
    SQL
  end

  def restrictions
    if senders && senders.kind_of?(Array)
      senders_as_string = senders.inject('') { |acc, val| acc + "'#{val}'," }[0...-1]
      "data->>'sender_id' IN (#{senders_as_string})"
    else
      'true'
    end
  end
end
