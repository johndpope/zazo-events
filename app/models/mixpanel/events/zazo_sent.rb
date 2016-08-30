class Mixpanel::Events::ZazoSent < Mixpanel::Events
  def user
    e.data['sender_id']
  end

  def data
    { 'target_mkey' => e.data['receiver_id'] }
  end
end
