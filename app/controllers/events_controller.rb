class EventsController < ApplicationController
  def index
    render json: []
  end

  def create
    render json: 'ok'
  end

  def heartbeat
    render json: { app_name: Settings.app_name, version: Settings.version }
  end
end
