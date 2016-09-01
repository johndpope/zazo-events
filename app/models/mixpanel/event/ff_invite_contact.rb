class Mixpanel::Event::FfInviteContact < Mixpanel::Event
  def user
    e.initiator_id
  end

  def specific_data
    { 'triggered_by' => 'api',
      'contact' => e.data['zazo_mkey'] }
  end
end
