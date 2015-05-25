class Api::V1::MetricsController < ApplicationController
  before_action :validate_group_by

  def show
    render json: Metric.find(params[:id]).new(metric_parameters).generate
  rescue Metric::UnknownMetric => error
    render json: { error: error.message }, status: :not_found
  end

  def index
    render json: Metric.all.map { |klass| klass.name.demodulize.underscore }
  end

  private

  def metric_parameters
    params.permit(:group_by, :user_id)
  end
end
