class ApplicationController < ActionController::API
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    head :not_found
  end

  def render_error(error)
    render json: { error: error }, status: :unprocessable_entity
  end

  def validate_group_by
    @group_by = params[:group_by].try(:to_sym) || :day
    @group_by.in?(Groupdate::FIELDS) || render_error("invalid group_by value: #{@group_by.inspect}, valid fields are #{Groupdate::FIELDS}")
  end
end
