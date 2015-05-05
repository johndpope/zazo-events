class Event < ActiveRecord::Base
  SOURCES = %w(aws:s3 zazo:api zazo:ios zazo:android).freeze

  validates :name, :triggered_at, :triggered_by, :initiator,
            presence: true

  validates :triggered_by, inclusion: { in: SOURCES }

  default_scope -> { order(:triggered_at) }

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
