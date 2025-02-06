class Api::V1::UsersController < Api::BaseController
  before_action :authenticate_user!, except: %i[create login]
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.includes(:profile).all
    render json: @users, status: :ok
  end

  def show
    render json: @user, include: %i[profile reviews], status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      token = JsonWebToken.encode(user_id: @user.id)
      render json: {
        user: @user,
        token: token,
        message: "User created successfully"
      }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by(email: params[:email])
    if @user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: @user.id)
      render json: {
        user: @user,
        token: token
      }, status: :ok
    else
      render json: { error: "Invalid credentials" }, status: :unauthorized
    end
  end

  def update
    if @user.update(user_params)
      render json: @user, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, 
             status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    head :no_content
  end

  def profile
    render json: current_user,
           include: %i[profile reviews bookings],
           status: :ok
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "User not found" }, status: :not_found
  end

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :password_confirmation,
      :user_type,
      profile_attributes: [
        :first_name,
        :last_name,
        :phone_number,
        :bio,
        :avatar
      ]
    )
  end
end
