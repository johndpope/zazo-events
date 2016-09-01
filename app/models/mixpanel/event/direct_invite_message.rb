class Mixpanel::Event::DirectInviteMessage < Mixpanel::Event
  def user
    e.initiator_id
  end

  def specific_data
    { 'inviter' => e.data['inviter_id'],
      'invitee' => e.data['invitee_id'],
      'messaging_platform' => e.data['messaging_platform'],
      'message_status' => e.data['message_status'] }
  end
end
