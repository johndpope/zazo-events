class Mixpanel::Event
  attr_reader :e

  def initialize(original_event = nil)
    @e = original_event
  end

  def allowed_to_send?
    !Rails.env.test?
  end

  def name
    self.class.to_s.split('::').last.underscore
  end

  def user
    ''
  end

  def data
    common_data.merge(specific_data)
  end

  def to_hash
    { name: name,
      user: user,
      data: data }
  end

  def to_s
    to_hash.to_s
  end

  def to_a
    [name, user, data]
  end

  protected

  def specific_data
    {}
  end

  private

  def common_data
    { 'event_id' => e.id,
      'time' => e.triggered_at.to_i }
  end
end
