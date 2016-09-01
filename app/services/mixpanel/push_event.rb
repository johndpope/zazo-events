class Mixpanel::PushEvent
  attr_reader :event, :tracker

  def initialize(original_event)
    @event = Mixpanel::BuildEvent.new(original_event).perform
    @tracker = Mixpanel::Tracker.new(Figaro.env.mixpanel_app_token)
  end

  def perform
    if event.allowed_to_send?
      tracker.import(Figaro.env.mixpanel_api_key, event.user, event.name, event.data)
      Rails.logger.info("Event was sent to mixpanel: #{event}")
    end
  end
end
