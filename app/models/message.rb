class Message
  DELIVERED_STATUSES = %i(downloaded viewed).freeze
  attr_reader :filename

  def self.by_direction(sender_id, receiver_id)
    filenames = Event.by_name(%w(video s3 uploaded))
                .with_sender(sender_id)
                .with_receiver(receiver_id)
                .order(:triggered_at)
                .pluck("data->>'video_filename'")
    filenames.map { |fn| new fn }
  end

  # @param filename
  # @param events
  def initialize(filename)
    @filename = filename
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
    fail 'no video:s3:uploaded event found' if @s3_event.blank?
    @s3_event
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
