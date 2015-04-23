class Event < ActiveRecord::Base
  SOURCES = %w(aws:s3 zazo:api zazo:ios zazo:android).freeze

  validates :name, :triggered_at, :triggered_by, :initiator, :initiator_id,
            presence: true

  validates :triggered_by, inclusion: { in: SOURCES }
end
