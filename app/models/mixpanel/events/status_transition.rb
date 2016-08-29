class Mixpanel::Events::StatusTransition < Mixpanel::Events
  def user
    orig_event.initiator_id
  end

  def data
    { 'previous_status' => orig_event.data['from_state'],
      'current_status'  => orig_event.data['to_state'] }
  end
end
