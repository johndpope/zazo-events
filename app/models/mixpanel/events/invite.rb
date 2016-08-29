class Mixpanel::Events::Invite < Mixpanel::Events
  def user
    orig_event.initiator_id
  end

  def data
    { 'target_mkey' => orig_event.target_id }
  end
end
