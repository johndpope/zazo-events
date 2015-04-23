class Api::V1::EventsController < ApplicationController
  def index
    render json: []
  end

  def create
    render json: params, status: :created
  end

  def show
    render json: {}
  end
end
