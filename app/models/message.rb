class Message
  attr_reader :event

  def initialize(event)
    @event = event
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

  def to_hash
    { sender_id: data.sender_id,
      receiver_id: data.receiver_id,
      filename: filename,
      date: date,
      size: size }
  end

  def status
    last_event.name.last.to_sym
  end

  def last_event
    Event.with_video_filename(filename).order(:triggered_at).last
  end
end
