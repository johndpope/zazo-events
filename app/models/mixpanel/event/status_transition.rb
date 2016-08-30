class Mixpanel::Event::StatusTransition < Mixpanel::Event
  def user
    e.initiator_id
  end

  def data
    { 'previous_status' => e.data['from_state'],
      'current_status'  => e.data['to_state'] }
  end
end
