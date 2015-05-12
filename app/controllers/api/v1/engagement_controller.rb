class Api::V1::EngagementController < ApplicationController
  def messages_sent
    @events = Event.by_name(%w(video s3 uploaded)).group_by_day(:triggered_at).count
    render json: @events
  end
end
