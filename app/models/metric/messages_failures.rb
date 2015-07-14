class Metric::MessagesFailures < Metric::Base
  def generate
    messages.each_with_object(sample) do |message, data|
      data[:sent] += 1
      message.delivered? && data[:received] += 1
      message.undelivered? && data[:not_received] += 1
      message.status.uploaded? && data[:incomplete] += 1
      message.missing_events.include?(%w(video kvstore received)) &&
        data[:missing_kvstore_received] += 1
      message.missing_events.include?(%w(video notification received)) &&
        data[:missing_notification_received] += 1
      message.missing_events.include?(%w(video kvstore downloaded)) &&
        data[:missing_kvstore_downloaded] += 1
      message.missing_events.include?(%w(video notification downloaded)) &&
        data[:missing_notification_downloaded] += 1
      message.missing_events.include?(%w(video kvstore viewed)) &&
        data[:missing_kvstore_viewed] += 1
      message.missing_events.include?(%w(video notification viewed)) &&
        data[:missing_notification_viewed] += 1
    end
  end

  private

  def sample
    {  sent: 0,
       received: 0,
       not_received: 0,
       incomplete: 0,
       missing_kvstore_received: 0,
       missing_notification_received: 0,
       missing_kvstore_downloaded: 0,
       missing_notification_downloaded: 0,
       missing_kvstore_viewed: 0,
       missing_notification_viewed: 0 }
  end

  def messages
    Message.all(start_date: start_date, end_date: end_date)
  end

  def start_date
    12.days.ago
  end

  def end_date
    2.days.ago
  end
end
