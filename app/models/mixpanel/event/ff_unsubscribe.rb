class Mixpanel::Event::FfUnsubscribe < Mixpanel::Event
  def user
    e.initiator_id
  end

  def specific_data
    { 'triggered_by' => 'api' }
  end
end
