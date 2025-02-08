class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include ActionController::RequestForgeryProtection

  protect_from_forgery with: :exception

  # Error handling
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
  rescue_from ActionController::ParameterMissing, with: :bad_request
  rescue_from JWT::DecodeError, with: :unauthorized

  protected

  # Authentication helpers
  def authenticate_user!
    unless current_user
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def current_user
    @current_user ||= begin
      token = request.headers["Authorization"]&.split(" ")&.last
      return nil unless token

      decoded = Authentication::JwtService.decode(token)
      User.find_by(id: decoded["user_id"]) if decoded
    end
  end

  # Response helpers
  def json_response(object, status = :ok, meta = {})
    response = {
      status: status,
      data: object
    }
    response[:meta] = meta if meta.present?
    render json: response, status: status
  end

  def verify_authenticity_token
    unless request.format.json?
      verify_csrf_token
    end
  end

  private

  # Error handlers
  def not_found(exception)
    render json: {
      error: "Record not found",
      details: exception.message
    }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: {
      error: "Validation failed",
      details: exception.record.errors.full_messages
    }, status: :unprocessable_entity
  end

  def bad_request(exception)
    render json: {
      error: "Bad request",
      details: exception.message
    }, status: :bad_request
  end

  def unauthorized(exception)
    render json: {
      error: "Unauthorized",
      details: exception.message
    }, status: :unauthorized
  end

  # Parameter sanitization
  def sanitize_page_params
    params[:page] = (params[:page] || 1).to_i
    params[:per_page] = (params[:per_page] || 25).to_i
  end

  def verify_csrf_token
    if !valid_authenticity_token?(session, form_authenticity_param)
      raise ActionController::InvalidAuthenticityToken
    end
  end
end
