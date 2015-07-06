class Metric::MessagesStatusesBetweenUsers < Metric::Base
  attr_accessor :user_id, :friend_ids
  after_initialize :set_attributes
  validates :user_id, :friend_ids, presence: true

  def generate
    initial = { total: { outgoing: data_sample, incoming: data_sample } }
    build_outgoing_messages
    build_incoming_messages
    friend_ids.each_with_object(initial) do |friend_id, results|
      results[friend_id] = { outgoing: reduce(@outgoing_messages[friend_id]),
                             incoming: reduce(@incoming_messages[friend_id]) }
      calculate_total(:outgoing, results, friend_id)
      calculate_total(:incoming, results, friend_id)
    end
  end

  protected

  def set_attributes
    @user_id = attributes['user_id']
    @friend_ids = Array.wrap(attributes['friend_ids'])
  end

  def data_sample(default = 0)
    { sent: default, incomplete: default, unviewed: default }
  end

  def outgoing_events
    Event.with_sender(user_id).with_receivers(friend_ids).order(:triggered_at)
      .pluck(:name, "data->>'video_filename'", "data->>'receiver_id'")
  end

  def build_outgoing_messages
    @outgoing_messages = group_events(outgoing_events)
  end

  def incoming_events
    Event.with_senders(friend_ids).with_receiver(user_id).order(:triggered_at)
      .pluck(:name, "data->>'video_filename'", "data->>'sender_id'")
  end

  def build_incoming_messages
    @incoming_messages = group_events(incoming_events)
  end

  def group_events(flat_events)
    data = flat_events.group_by { |row| row[2] }
    data.each_with_object({}) do |(friend_id, events), result|
      result[friend_id] = build_messages(events.group_by { |row| row[1] })
    end
  end

  def build_messages(hash)
    hash.map do |file_name, rows|
      Message.new(file_name, event_names: rows.map(&:first))
    end
  end

  def reduce(messages)
    return data_sample if messages.blank?
    messages.each_with_object(data_sample) do |message, results|
      results[:sent] += 1
      results[:incomplete] += 1 if message.incomplete?
      results[:unviewed] += 1 if message.unviewed?
    end
  end

  def calculate_total(subject, memo, friend_id)
    total = memo[:total][subject]
    total.each_with_object(total) do |(key, value), result|
      result[key] = value + memo[friend_id][subject][key]
    end
  end
end
