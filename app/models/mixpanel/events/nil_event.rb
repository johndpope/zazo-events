class Mixpanel::Events::NilEvent < Mixpanel::Events
  def allowed_to_send?
    false
  end
end
