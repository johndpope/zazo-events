class Api::V1::EngagementController < ApplicationController
  before_action :validate_group_by

  def messages_sent
    render json: Event.by_name(%w(video s3 uploaded)).send(:"group_by_#{@group_by}", :triggered_at).count
  end

  private

  def validate_group_by
    @group_by = params[:group_by].try(:to_sym) || :day
    @group_by.in?(Groupdate::FIELDS) || render_error("invalid group_by value: #{@group_by.inspect}, valid fields are #{Groupdate::FIELDS}")
  end
end
