class Metric::Filter::NonMarketing < Metric::Base
  include Metric::Filter

  def generate
    Event.connection.select_all query
  end

  private

  def query
    <<-SQL
      WITH invited AS (
        SELECT
          initiator_id invitee,
          MAX(triggered_at) time_zero
        FROM events
        WHERE name @> ARRAY['user', 'invited']::VARCHAR[]
        GROUP BY invitee
      ) SELECT
          invited.invitee invitee,
          events.initiator_id inviter,
          invited.time_zero
        FROM events
          INNER JOIN invited ON events.target_id = invited.invitee
        WHERE
          name @> ARRAY['user', 'invitation_sent']::VARCHAR[] AND
          EXTRACT(EPOCH FROM events.triggered_at - invited.time_zero) < 1
    SQL
  end
end
