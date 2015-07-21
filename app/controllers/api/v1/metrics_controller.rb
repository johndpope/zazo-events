class Api::V1::MetricsController < ApplicationController
  def show
    if params[:prefix]
      @metric = Metric.find(params[:id], params[:prefix]).new(metric_parameters)
    else
      @metric = Metric.find(params[:id]).new(metric_parameters)
    end

    if @metric.valid?
      render json: @metric.generate
    else
      Rollbar.warning('Attempt to get invalid metric', errors: @metric.errors.messages)
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
    params.except(:controller, :action, :id, :prefix)
  end
end
