class Api::V1::MetricsController < ApplicationController
  before_action :validate_group_by

  def show
    render json: Metric.find(params[:id]).new(group_by: @group_by).generate
  rescue Metric::UnknownMetric => error
    render json: { error: error.message }, status: :not_found
  end

  def index
    render json: Metric.all.map { |klass| klass.name.demodulize.underscore }
  end
end
