class Metric::MessagesFailures < Metric::Base
  after_initialize :set_attributes
  attr_reader :start_date, :end_date

  def self.type
    :messages_failures
  end

  def generate
    { meta: meta, data: data }
  end

  protected

  def set_attributes
    @start_date = get_attribute_value 'start_date'
    @end_date   = get_attribute_value 'end_date'
  end

  def get_attribute_value(variable)
    Time.parse attributes[variable]
  rescue ArgumentError, TypeError
    default_attribute_value variable
  end

  def default_attribute_value(attr)
    case attr
      when 'start_date' then FAR_IN_PAST_DATE
      when 'end_date'   then IN_FAR_FUTURE_DATE
      else FAR_IN_PAST_DATE
    end
  end

  def sample
    { uploaded: 0,
      delivered: 0,
      undelivered: 0,
      incomplete: 0,
      missing_kvstore_received: 0,
      missing_notification_received: 0,
      missing_kvstore_downloaded: 0,
      missing_notification_downloaded: 0,
      missing_kvstore_viewed: 0,
      missing_notification_viewed: 0 }
  end

  def aggregated_by_platforms
    { ios_to_ios: sample,
      ios_to_android: sample,
      android_to_android: sample,
      android_to_ios: sample,
      unknown_to_unknown: sample }
  end

  def events_scope
    Event.since(start_date).till(end_date + 1)
  end

  def messages
    @messages ||= Message.build_from_events_scope(events_scope)
  end

  def meta
    { total: :uploaded, start_date: start_date, end_date: end_date }
  end

  def data
    messages.each_with_object(aggregated_by_platforms) do |message, result|
      direction = :"#{message.sender_platform}_to_#{message.receiver_platform}"
      result[direction] = handle_data_by_message result.fetch(direction, sample), message
    end
  end

  def handle_data_by_message(data, message)
    missing_events = message.missing_events
    data[:uploaded]    += 1
    data[:delivered]   += 1 if message.delivered?
    data[:undelivered] += 1 if message.undelivered?
    data[:incomplete]  += 1 if message.status.uploaded?
    data[:missing_kvstore_received]        += 1 if missing_events.include?(%w(video kvstore received))
    data[:missing_notification_received]   += 1 if missing_events.include?(%w(video notification received))
    data[:missing_kvstore_downloaded]      += 1 if missing_events.include?(%w(video kvstore downloaded))
    data[:missing_notification_downloaded] += 1 if missing_events.include?(%w(video notification downloaded))
    data[:missing_kvstore_viewed]          += 1 if missing_events.include?(%w(video kvstore viewed))
    data[:missing_notification_viewed]     += 1 if missing_events.include?(%w(video notification viewed))
    data
  end
end
