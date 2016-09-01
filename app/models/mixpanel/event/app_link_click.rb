class Mixpanel::Event::AppLinkClick < Mixpanel::Event
  def user
    e.data['link_key'] == 'l' ?
      e.data['inviter_mkey'] :
      e.data['connection_creator_mkey']
  end

  def data
    base = {
      'link_key' => e.data['link_key'],
      'platform' => e.data['platform'] }
    if e.data['link_key'] == 'l'
      base.merge(
        'inviter' => e.data['inviter_mkey'])
    else
      base.merge(
        'inviter' => e.data['connection_creator_mkey'],
        'target' => e.data['connection_target_mkey'])
    end
  end
end
