class Api::V1::MessagesController < ApplicationController
  before_action :set_message, only: [:show, :events]

  def index
    @messages = Message.all(messages_params)
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

  def messages_params
    params[:page] ||= 1
    params.permit(:sender_id, :receiver_id, :reverse, :page, :per)
  end
end
