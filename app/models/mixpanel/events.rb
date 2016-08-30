class Mixpanel::Events
  attr_reader :e

  def initialize(original_event = nil)
    @e = original_event
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
