
class Api::V1::AuthController < Api::BaseController
  skip_before_action :authenticate_request, except: %i[refresh_token logout]
  skip_before_action :authenticate_user!, except: %i[refresh_token logout]


  def register
    user = User.new(user_params)

    if user.save!
      token = Authentication::JwtService.encode(user_id: user.id)

      render json: {
        user: UserSerializer.new(user),
        token: token,
        message: "Registration successful. Please verify your email."
      }, status: :created
    else
      render json: { errors: user.errors.full_messages, params: user_params },
              status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      if user.verified?
        token = Authentication::JwtService.encode(user_id: user.id)
        render json: {
          user: UserSerializer.new(user),
          token: token
        }
      else
        render json: { error: "Please verify your email" }, 
                status: :unauthorized
      end
    else
      render json: { error: "Invalid credentials" }, 
              status: :unauthorized
    end
  end

  def verify_email
    user = User.find_by(verification_token: params[:token])

    render json: { message: "User already verified." } and return if user&.verified?

    if user&.verify_email(params[:token])
      render json: { message: "Email verified successfully" }
    else
      render json: { error: "Invalid verification token" },
              status: :unprocessable_entity
    end
  end

  def forgot_password
    user = User.find_by(email: params[:email])

    if user
      user.generate_password_reset_token
      UserMailer.reset_password_email(user).deliver_later
      render json: { message: "Password reset instructions sent" }
    else
      render json: { error: "Email not found" }, 
              status: :not_found
    end
  end

  def reset_password
    user = User.find_by(reset_password_token: params[:token])

    if user&.reset_password(params[:password])
      render json: { message: "Password reset successful" }
    else
      render json: { error: "Invalid or expired token" },
              status: :unprocessable_entity
    end
  end

  def refresh_token
    new_token = Authentication::JwtService.encode(user_id: current_user.id)
    render json: { token: new_token }
  end

  # TODO: Implement social authentication
  def social_auth
    auth_data = request.env["omniauth.auth"]
    result = Authentication::OauthService.authenticate(auth_data)

    if result[:user]
      render json: {
        user: UserSerializer.new(result[:user]),
        token: result[:token]
      }
    else
      render json: { error: "Authentication failed" }, 
              status: :unauthorized
    end
  end

  def logout
    current_token = request.headers["Authorization"]&.split(" ")&.last
    current_user.invalidate_token(current_token)
    render json: { message: "Logout successful" }
  end

  private

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation, :role,
      profile_attributes: %i[first_name last_name phone_number]
    )
  end
end
