class Api::V1::StatusController < ApplicationController
  def index
    render json: { app_name: Settings.app_name, version: Settings.version }
  end

  def heartbeat
    render text: 'OK'
  end
end
