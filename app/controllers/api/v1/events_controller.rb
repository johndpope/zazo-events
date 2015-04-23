class Api::V1::EventsController < ApplicationController
  def index
    render json: Event.all
  end

  def create
    return create_s3_event if params.key?('Records')
    @event = Event.new(event_params.merge(raw_data: event_params[:event]))
    if @event.valid?
      @event.save
      render json: @event, status: :created
    else
      render json: { errors: @event.errors }, status: :unprocessable_entity
    end
  end

  def show
    @event = Event.find(params[:id])
    render json: @event
  end

  private

  def event_params
    params.permit(:event).permit(:name, :triggered_at, :triggered_by, :initiator, :initiator_id)
  end

  def create_s3_event
    @events = Event.create_from_s3_event(params)
    render json: @events, status: :created
  rescue TypeError, ArgumentError => error
    render json: { errors: [error.message] }, status: :unprocessable_entity
  end
end
