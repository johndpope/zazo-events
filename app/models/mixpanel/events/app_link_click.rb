class Mixpanel::Events::AppLinkClick < Mixpanel::Events
  def user
    orig_event.data['link_key'] == 'l' ?
      orig_event.data['inviter_mkey'] :
      orig_event.data['connection_creator_mkey']
  end

  def data
    base = {
      'link_key' => orig_event.data['link_key'],
      'platform' => orig_event.data['platform'] }
    if orig_event.data['link_key'] == 'l'
      base.merge(
        'inviter_mkey' => orig_event.data['inviter_mkey'])
    else
      base.merge(
        'inviter_mkey' => orig_event.data['connection_creator_mkey'],
        'target_mkey'  => orig_event.data['connection_target_mkey'])

    end
  end
end
