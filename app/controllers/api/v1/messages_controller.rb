class Api::V1::MessagesController < ApplicationController
  before_action :set_message, only: [:show, :events]

  def index
    events = if params[:sender_id] && params[:receiver_id]
               Message.by_direction_events(params[:sender_id], params[:receiver_id], params[:reverse])
             else
               Message.all_events(params[:reverse])
    end
    @messages = events.page(params[:page]).per(params[:per]).map { |e| Message.new(e) }
    render json: @messages
  end

  def show
    render json: @message
  end

  def events
    render json: @message.events
  end

  private

  def set_message
    @message = Message.new(params[:id])
  end
end
