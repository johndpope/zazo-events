class Mixpanel::Events::StatusTransition < Mixpanel::Events
  def user
    e.initiator_id
  end

  def data
    { 'previous_status' => e.data['from_state'],
      'current_status'  => e.data['to_state'] }
  end
end
