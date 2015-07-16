class Metric::MessagesFailures < Metric::Base
  after_initialize :set_attributes
  attr_reader :start_date, :end_date

  def generate
    { meta: meta, data: data }
  end

  private

  def set_attributes
    @start_date = attributes.fetch('start_date', default_start_date).to_date
    @end_date = attributes.fetch('end_date', default_end_date).to_date
  end

  def default_start_date
    12.days.ago
  end

  def default_end_date
    2.days.ago
  end

  def sample
    {  uploaded: 0,
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

  def events
    @events ||= Event.since(start_date).till(end_date + 1)
                .group("data->>'video_filename'", :name)
                .count
  end

  def messages
    return @messages if @messages
    @messages = events.group_by { |row, _count| row.first }
    @messages.map do |file_name, row|
      next if file_name.nil?
      Message.new(file_name, event_names: row.map { |r| r[0][1] })
    end.compact
  end

  def meta
    { total: :uploaded, start_date: start_date, end_date: end_date }
  end

  def data
    messages.each_with_object(sample) do |message, data|
      data[:uploaded] += 1
      data[:delivered] += 1 if message.delivered?
      data[:undelivered] += 1 if message.undelivered?
      data[:incomplete] += 1 if message.status.uploaded?
      if message.missing_events.include?(%w(video kvstore received))
        data[:missing_kvstore_received] += 1
      end
      if message.missing_events.include?(%w(video notification received))
        data[:missing_notification_received] += 1
      end
      if message.missing_events.include?(%w(video kvstore downloaded))
        data[:missing_kvstore_downloaded] += 1
      end
      if message.missing_events.include?(%w(video notification downloaded))
        data[:missing_notification_downloaded] += 1
      end
      if message.missing_events.include?(%w(video kvstore viewed))
        data[:missing_kvstore_viewed] += 1
      end
      if message.missing_events.include?(%w(video notification viewed))
        data[:missing_notification_viewed] += 1
      end
    end
  end
end
