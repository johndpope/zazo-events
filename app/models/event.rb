class Event < ActiveRecord::Base
  SOURCES = %w(aws:s3 zazo:api zazo:ios zazo:android).freeze

  validates :name, :triggered_at, :triggered_by, :initiator, :initiator_id,
            presence: true

  validates :triggered_by, inclusion: { in: SOURCES }

  def self.create_from_s3_event(records)
    Array.wrap(records).map do |record|
      create_from_s3_record(record)
    end
  end

  def self.create_from_s3_record(raw_record)
    fail TypeError, 'record must be a Hash' unless raw_record.is_a?(Hash)
    fail ArgumentError, 'record must be a S3 event hash' unless raw_record.key?('eventName')
    record = Hashie::Mash.new(raw_record)
    event = new
    event.name = record.eventName.include?('ObjectCreated') && 'video:sent' || record.eventName
    event.triggered_by = record.eventSource
    event.triggered_at = record.eventTime.to_datetime
    event.initiator = 'user'
    video_filename = record.s3.object[:key]
    event.data = { video_filename: video_filename }
    initiator_id, target_id, _hash = video_filename.split('-')
    event.initiator_id = initiator_id
    event.target = 'user'
    event.target_id = target_id
    event.raw_params = raw_record
    event.save! && event
  end

  def self.create_from_params(params)
    if params.is_a?(Array)
      create_from_s3_event(params)
    else
      create(params.merge(raw_params: params))
    end
  end
end
