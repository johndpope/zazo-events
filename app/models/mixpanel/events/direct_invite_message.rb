class Mixpanel::Events::DirectInviteMessage < Mixpanel::Events
  def user
    orig_event.initiator_id
  end

  def data
    { 'inviter_id'         => orig_event.data['inviter_id'],
      'invitee_id'         => orig_event.data['invitee_id'],
      'messaging_platform' => orig_event.data['messaging_platform'],
      'message_status'     => orig_event.data['message_status'] }
  end
end
