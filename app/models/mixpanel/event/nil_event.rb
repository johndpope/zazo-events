class Mixpanel::Event::NilEvent < Mixpanel::Event
  def allowed_to_send?
    false
  end
end
