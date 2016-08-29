class Mixpanel::BuildEvent
  NAME_TO_TYPE = {
    %w(video kvstore received)                => :zazo_sent,
    %w(text kvstore received)                 => :text_sent,
    %w(user invited)                          => :status_transition,
    %w(user initialized)                      => :status_transition,
    %w(user registered)                       => :status_transition,
    %w(user verified)                         => :status_transition,
    %w(user invitation_sent)                  => :invite,
    %w(user app_link_clicked)                 => :app_link_click,
    %w(user invitation direct_invite_message) => :direct_invite_message }

  attr_reader :orig_event

  def initialize(orig_event)
    @orig_event = orig_event
  end

  def perform
    name_type = NAME_TO_TYPE.find { |name,_| orig_event.name == name }
    name_type ? event_by_type(name_type.last) : Mixpanel::Events::NilEvent.new
  end

  private

  def event_by_type(type)
    klass = Zazo::Tool::Classifier.new([:mixpanel, :events, type]).klass
    klass.new(orig_event)
  end
end
