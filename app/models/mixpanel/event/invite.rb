class Mixpanel::Event::Invite < Mixpanel::Event
  def user
    e.initiator_id
  end

  def data
    { 'target' => e.target_id }
  end
end
