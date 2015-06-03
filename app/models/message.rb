class Message
  DELIVERED_STATUSES = %i(downloaded viewed).freeze
  attr_reader :event

  def self.all_events
    Event.by_name(%w(video s3 uploaded)).order(:triggered_at)
  end

  def self.by_connection_events(sender_id, receiver_id)
    all_events.with_sender(sender_id).with_receiver(receiver_id)
  end

  def self.all
    all_events.map { |e| new(e) }
  end

  def self.by_connection(sender_id, receiver_id)
    by_connection_events(sender_id, receiver_id).map { |e| new(e) }
  end

  def self.find(filename)
    events = Event.by_name(%w(video s3 uploaded)).with_video_filename(filename)
    !events.empty? && new(events.first)
  end

  # @param event [Event] - video:s3:uploaded from S3
  def initialize(event)
    @event = event
  end

  def ==(message)
    message.is_a?(self.class) && filename == message.filename
  end

  def to_hash
    { sender_id: data.sender_id,
      receiver_id: data.receiver_id,
      filename: filename,
      date: date,
      size: size,
      status: status,
      delivered: delivered? }
  end

  def data
    @data ||= Hashie::Mash.new(event.data)
  end

  def raw_params
    @raw_params ||= Hashie::Mash.new(event.raw_params)
  end

  def filename
    data.video_filename
  end

  def date
    event.triggered_at
  end

  def size
    raw_params.s3.object['size']
  end

  def events
    Event.with_video_filename(filename).order(:triggered_at)
  end

  def status
    events.last.name.last.to_sym
  end

  def delivered?
    DELIVERED_STATUSES.include?(status)
  end

  def undelivered?
    !delivered?
  end
end
