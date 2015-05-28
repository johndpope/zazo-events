class Event < ActiveRecord::Base
  SOURCES = %w(aws:s3 zazo:api zazo:ios zazo:android).freeze

  validates :name, :triggered_at, :triggered_by, :initiator,
            presence: true

  validates :triggered_by, inclusion: { in: SOURCES }

  scope :since, ->(time) { where('triggered_at >= ?', time) }
  scope :today, -> { since(Date.today) }
  scope :top_namespace, ->(namespace) { where('name[1] = ?', namespace) }
  scope :by_initiator, ->(initiator, initiator_id) { where(initiator: initiator, initiator_id: initiator_id) }
  scope :by_target, ->(target, target_id) { where(target: target, target_id: target_id) }
  scope :by_name, ->(name) { where('name = ARRAY[?]::varchar[]', name) }
  scope :with_sender, -> (user_id){ where("data->>'sender_id' = ?", user_id) }
  scope :with_receiver, -> (user_id){ where("data->>'receiver_id' = ?", user_id) }

  paginates_per 100

  def self.by_tokens(tokens)
    tokens = Array(tokens)
    tokens_pattern = "%(#{tokens.join('|')})%"
    where('initiator_id IN (:tokens) OR target_id IN (:tokens) OR data::text SIMILAR TO :tokens_pattern',
              tokens: tokens, tokens_pattern: tokens_pattern)
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
    event.data = { sender_id: sender_id,
                   receiver_id: receiver_id,
                   video_filename: video_filename }
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
end
