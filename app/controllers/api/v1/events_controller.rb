class Api::V1::EventsController < ApplicationController
  def index
    render json: Event.all
  end

  def create
    @event = Event.create_from_params(event_params)
    return render json: @event, status: :created if @event.is_a?(Array)
    if @event.valid?
      render json: @event, status: :created
    else
      render json: { errors: @event.errors }, status: :unprocessable_entity
    end
  rescue TypeError, ArgumentError => error
    render json: { errors: [error.message] }, status: :unprocessable_entity
  end

  def show
    @event = Event.find(params[:id])
    render json: @event
  end

  private

  def event_params
    if params.key?('Records')
      params.require('Records')
    else
      params.permit(:name, :triggered_at, :triggered_by, :initiator,
                    :initiator_id, :target, :target_id, data: params[:data].try(:keys))
    end
  end
end
