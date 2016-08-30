class Mixpanel::PushEvent
  attr_reader :event, :tracker

  def initialize(event)
    @event = event
    @tracker = Mixpanel::Tracker.new(Figaro.env.mixpanel_app_token)
  end

  def perform
    tracker.import(
      Figaro.env.mixpanel_api_key,
      event.user, event.name, event.data) if event.allowed_to_send?
  end
end
