class Event < ActiveRecord::Base
  SOURCES = %w(aws:s3 zazo:api zazo:ios zazo:android).freeze

  validates :name, :triggered_at, :triggered_by, :initiator, :initiator_id,
            presence: true

  validates :triggered_by, inclusion: { in: SOURCES }

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
    event.name = record.eventName.include?('ObjectCreated') && 'video:s3:uploaded' || record.eventName
    event.triggered_by = record.eventSource
    event.triggered_at = record.eventTime.to_datetime
    event.initiator = 'user'
    video_filename = record.s3.object[:key]
    sender_id, receiver_id, _hash = video_filename.split('-')
    event.data = { sender_id: sender_id,
                   receiver_id: receiver_id,
                   video_filename: video_filename }
    event.initiator_id = sender_id
    event.target = 'user'
    event.target_id = receiver_id
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
      create(params.merge(message_id: message_id))
    end
  end
end
