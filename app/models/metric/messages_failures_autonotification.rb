class Metric::MessagesFailuresAutonotification < Metric::MessagesFailures
  def data
    messages.each_with_object(aggregated_by_platforms.except(:unknown_to_unknown)) do |message, result|
      if message.data.client_platform == 'android' && message.data.client_version.to_i >= 112
        direction = :"#{message.data.client_platform}_to_#{message.receiver_platform}"
        result[direction] = handle_data_by_message result.fetch(direction, sample), message
      end
    end
  end
end
