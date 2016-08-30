class Mixpanel::Events::DirectInviteMessage < Mixpanel::Events
  def user
    e.initiator_id
  end

  def data
    { 'inviter_id'         => e.data['inviter_id'],
      'invitee_id'         => e.data['invitee_id'],
      'messaging_platform' => e.data['messaging_platform'],
      'message_status'     => e.data['message_status'] }
  end
end
