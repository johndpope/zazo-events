class Api::V1::MetricsController < ApplicationController
  before_action :validate_group_by

  def show
    render json: Metric.build(params[:id]).new(group_by: @group_by).generate
  rescue Metric::UnknownMetric => error
    render json: { error: error.message }, status: :not_found
  end
end
