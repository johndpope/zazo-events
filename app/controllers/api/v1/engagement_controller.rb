class Api::V1::EngagementController < ApplicationController
  before_action :validate_group_by

  def messages_sent
    render json: Metric::MessagesSent.new(group_by: @group_by).generate
  end
end
