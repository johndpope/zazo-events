class Mixpanel::Events
  attr_reader :orig_event

  def initialize(orig_event = nil)
    @orig_event = orig_event
  end

  def allowed_to_send?
    true
  end

  def name
    self.class.to_s.split('::').last.underscore
  end

  def user
    ''
  end

  def data
    {}
  end
end
