class Message
  DELIVERED_STATUSES = %i(downloaded viewed).freeze
  attr_reader :filename
  alias_method :id, :filename

  def self.all_events(reverse = false)
    events = Event.by_name(%w(video s3 uploaded))
    if reverse
      events.order('triggered_at DESC')
    else
      events.order('triggered_at ASC')
    end
  end

  def self.all(reverse = false)
    all_events(reverse).map { |e| Message.new(e) }
  end

  def self.by_direction_events(sender_id, receiver_id, reverse = false)
    events = Event.by_name(%w(video s3 uploaded))
             .with_sender(sender_id)
             .with_receiver(receiver_id)
    if reverse
      events.order('triggered_at DESC')
    else
      events.order('triggered_at ASC')
    end
  end

  def self.by_direction(sender_id, receiver_id, reverse = false)
    by_direction_events(sender_id, receiver_id, reverse).map { |e| Message.new(e) }
  end

  # @param filename_or_event
  # @param events
  def initialize(filename_or_event)
    if !filename_or_event.is_a?(String) &&
       filename_or_event.is_a?(Event) &&
       filename_or_event.name != %w(video s3 uploaded)
      fail TypeError, 'value must be either filename or video:s3:uploaded event'
    end
    if filename_or_event.is_a?(String)
      @filename = filename_or_event
    else
      @s3_event = filename_or_event
      @filename = @s3_event.data['video_filename']
    end
  end

  def ==(message)
    message.is_a?(self.class) && filename == message.filename
  end

  def events
    @events ||= Event.with_video_filename(filename).order(:triggered_at)
  end

  def s3_event
    return @s3_event if @s3_event
    @s3_event = events.select { |e| e.name == %w(video s3 uploaded) }.first
    fail ActiveRecord::RecordNotFound, 'no video:s3:uploaded event found' if @s3_event.blank?
    @s3_event
  end

  def to_hash
    { id: id,
      sender_id: data.sender_id,
      receiver_id: data.receiver_id,
      filename: filename,
      date: date,
      size: size,
      status: status,
      delivered: delivered? }
  end

  def data
    @data ||= Hashie::Mash.new(s3_event.data)
  end

  def raw_params
    @raw_params ||= Hashie::Mash.new(s3_event.raw_params)
  end

  def date
    s3_event.triggered_at
  end

  def size
    raw_params.s3.object['size']
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
