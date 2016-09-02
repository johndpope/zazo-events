class Mixpanel::Event::ZazoSent < Mixpanel::Event
  def user
    e.initiator_id
  end

  def specific_data
    { 'type' => e.name.first,
      'sender_platform' => e.data['sender_platform'],
      'receiver' => e.data['receiver_id'],
      'receiver_platform' => e.data['receiver_platform'] }
  end
end
