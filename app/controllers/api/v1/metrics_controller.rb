class Api::V1::MetricsController < ApplicationController
  def show
    @metric = Metric.find(params[:id]).new(metric_parameters)
    if @metric.valid?
      render json: @metric.generate
    else
      render_errors @metric.errors
    end
  rescue Metric::UnknownMetric => error
    render json: { error: error.message }, status: :not_found
  end

  def index
    render json: Metric.all
  end

  private

  def metric_parameters
    params.except(:controller, :action, :id)
  end
end
