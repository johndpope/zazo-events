class Mixpanel::Event::FfInviteContact < Mixpanel::Event
  def user
    e.initiator_id
  end

  def data
    { 'triggered_by' => 'api',
      'contact' => e.data['zazo_mkey'] }
  end
end
