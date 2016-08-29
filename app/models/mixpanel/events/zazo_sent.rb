class Mixpanel::Events::ZazoSent < Mixpanel::Events
  def user
    orig_event.data['sender_id']
  end

  def data
    { 'target_mkey' => orig_event.data['receiver_id'] }
  end
end
