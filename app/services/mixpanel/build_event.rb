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

  attr_reader :e

  def initialize(original_event)
    @e = original_event
  end

  def perform
    name_type = NAME_TO_TYPE.find { |name,_| e.name == name }
    name_type ? event_by_type(name_type.last) : Mixpanel::Event::NilEvent.new
  end

  private

  def event_by_type(type)
    Zazo::Tool::Classifier.new([:mixpanel, :event, type]).klass.new(e)
  end
end
