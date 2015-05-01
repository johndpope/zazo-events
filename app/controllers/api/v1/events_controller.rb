class Api::V1::EventsController < ApplicationController
  before_action :skip_test_message, only: :create

  def index
    render json: Event.all
  end

  def create
    @event = Event.create_from_params(event_params, request.headers['X-Aws-Sqsd-Msgid'])
    return render json: @event if @event.is_a?(Array)
    if @event.valid?
      render json: @event
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

  def skip_test_message
    test_regexp = /test/i
    head :ok if params['Event'].try(:match, test_regexp) || params['name'].try(:match, test_regexp)
  end
end
