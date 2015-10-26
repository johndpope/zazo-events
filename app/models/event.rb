class Event < ActiveRecord::Base
  SOURCES = %w(aws:s3 zazo:api zazo:ios zazo:android).freeze

  validates :name, :triggered_at, :triggered_by, :initiator,
            presence: true

  validates :triggered_by, inclusion: { in: SOURCES }

  scope :since, ->(time) { where('triggered_at >= ?', time) }
  scope :till, ->(time) { where('triggered_at <= ?', time) }
  scope :today, -> { since(Date.today) }
  scope :top_namespace, ->(namespace) { where('name[1] = ?', namespace) }
  scope :by_initiator, ->(initiator, initiator_id) { where(initiator: initiator, initiator_id: initiator_id) }
  scope :by_target, ->(target, target_id) { where(target: target, target_id: target_id) }
  scope :by_name, ->(name) { where('name = ARRAY[?]::varchar[]', name) }
  scope :name_contains, ->(part) { where('name @> ARRAY[?]::varchar[]', part) }
  scope :name_overlap, ->(part) { where('name && ARRAY[?]::varchar[]', part) }
  scope :with_sender, -> (user_id) { where("data->>'sender_id' = ?", user_id) }
  scope :with_senders, -> (user_ids) { where("data->>'sender_id' IN (?)", user_ids) }
  scope :with_receiver, -> (user_id) { where("data->>'receiver_id' = ?", user_id) }
  scope :with_receivers, -> (user_ids) { where("data->>'receiver_id' IN (?)", user_ids) }
  scope :with_video_filename, -> (video_filename) { where("data->>'video_filename' = ?", video_filename) }
  scope :with_video_filenames, -> (video_filenames) { where("data->>'video_filename' IN (?)", video_filenames) }
  scope :video_s3_uploaded, -> { by_name(%w(video s3 uploaded)) }
  scope :s3_events, -> { name_overlap(%w(uploaded sent)) }

  paginates_per 100

  def self.filter_by(term)
    term = Array(term)
    term_pattern = "%(#{term.join('|')})%"
    where('initiator_id IN (:term) OR target_id IN (:term) OR data::text SIMILAR TO :term_pattern',
          term: term, term_pattern: term_pattern)
  end

  def self.create_from_s3_event(records, message_id = nil)
    Array.wrap(records).map do |record|
      create_from_s3_record(record, message_id)
    end
  end

  def self.create_from_s3_record(raw_record, message_id = nil)
    fail TypeError, 'record must be a Hash' unless raw_record.is_a?(Hash)
    fail ArgumentError, 'record must be a S3 event hash' unless raw_record.key?('eventName')
    record = Hashie::Mash.new(raw_record)
    event = new
    event.name = (record.eventName.include?('ObjectCreated') && 'video:s3:uploaded' || record.eventName).split(':')
    event.triggered_by = record.eventSource
    event.triggered_at = record.eventTime.to_datetime
    event.initiator = 's3'
    video_filename = record.s3.object[:key]
    sender_id, receiver_id, _hash = video_filename.split('-')
    client_info = S3Record::FetchClientInfo.new(raw_record).do

    event.data = { sender_id: sender_id,
                   receiver_id: receiver_id,
                   video_filename: video_filename,
                   client_platform: client_info[:client_platform],
                   client_version:  client_info[:client_version] }
    event.target = 'video'
    event.target_id = video_filename
    event.raw_params = raw_record
    event.message_id = message_id
    event.save! && event
  end

  def self.create_from_params(params, message_id = nil)
    event = find_by(message_id: message_id)
    return event if event
    if params.is_a?(Array)
      create_from_s3_event(params, message_id)
    else
      new_params = params.dup
      new_params[:name] = params[:name].split(':') if params[:name].is_a?(String)
      new_params[:message_id] = message_id
      create(new_params)
    end
  end

  def video_filename
    data['video_filename']
  end

  def sender_id
    data['sender_id']
  end

  def receiver_id
    data['receiver_id']
  end
end
