class Event < ActiveRecord::Base
  SOURCES = %w(aws:s3 zazo:api zazo:ios zazo:android).freeze

  validates :name, :triggered_at, :triggered_by, :initiator, :initiator_id,
            presence: true

  validates :triggered_by, inclusion: { in: SOURCES }
  serialize :raw_data

  def self.create_from_s3_event(raw_data)
    return if raw_data.blank?
    fail TypeError, 'raw_data must be a Hash-like object' unless raw_data.is_a?(Hash)
    fail ArgumentError, 'raw_data must be a S3 event' unless raw_data.key?('Records')
    raw_data['Records'].map do |raw_record|
      create_from_s3_record(raw_record)
    end
  end

  def self.create_from_s3_record(raw_record)
    record = Hashie::Mash.new(raw_record)
    event = new
    event.name = record.eventName.include?('ObjectCreated') && 'video:sent' || record.eventName
    event.triggered_by = record.eventSource
    event.triggered_at = record.eventTime.to_datetime
    event.initiator = 'user'
    initiator_id, target_id, _hash = record.s3.object[:key].split('-')
    event.initiator_id = initiator_id
    event.target = 'user'
    event.target_id = target_id
    event.raw_data = raw_record
    event.save! && event
  end
end
