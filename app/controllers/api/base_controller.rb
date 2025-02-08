
class Api::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_request
  before_action :authenticate_user!

  attr_reader :current_user

  protected

  def authenticate_request
    @current_user = Authentication::AuthenticationService.authenticate(request.headers)
    render_unauthorized unless @current_user
  end

  def render_unauthorized
    render json: { error: "Unauthorized access." }, status: :unauthorized
  end

  def render_error(message, status = :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def render_success(data, status = :ok)
    render json: data, status: status
  end

  def pagination_meta(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end

  private

  def authenticate_admin
    render_unauthorized unless current_user&.admin?
  end

  def validate_pagination_params
    params[:page] = (params[:page] || 1).to_i
    params[:per_page] = (params[:per_page] || 25).to_i
  end
end
