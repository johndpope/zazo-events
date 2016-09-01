class Mixpanel::BuildEvent
  NAME_TO_TYPE = {
    ['zazo:api', %w(video kvstore received)]                => :zazo_sent,
    ['zazo:api', %w(text kvstore received)]                 => :zazo_sent,
    ['zazo:api', %w(user invited)]                          => :status_transition,
    ['zazo:api', %w(user initialized)]                      => :status_transition,
    ['zazo:api', %w(user registered)]                       => :status_transition,
    ['zazo:api', %w(user verified)]                         => :status_transition,
    ['zazo:api', %w(user invitation_sent)]                  => :invite,
    ['zazo:api', %w(user app_link_clicked)]                 => :app_link_click,
    ['zazo:api', %w(user invitation direct_invite_message)] => :direct_invite_message,
    ['ff:api', %w(contact invited)]                         => :ff_invite_contact,
    ['ff:api', %w(contact added)]                           => :ff_add_contact,
    ['ff:api', %w(contact ignored)]                         => :ff_ignore_contact,
    ['ff:api', %w(settings subscribed)]                     => :ff_subscribe,
    ['ff:api', %w(settings unsubscribed)]                   => :ff_unsubscribe }

  attr_reader :e

  def initialize(original_event)
    @e = original_event
  end

  def perform
    name_type = NAME_TO_TYPE.find do |(triggered_by, name), _|
      e.triggered_by == triggered_by && e.name == name
    end
    name_type ? event_by_type(name_type.last) : Mixpanel::Event::NilEvent.new
  end

  private

  def event_by_type(type)
    Zazo::Tool::Classifier.new([:mixpanel, :event, type]).klass.new(e)
  end
end
