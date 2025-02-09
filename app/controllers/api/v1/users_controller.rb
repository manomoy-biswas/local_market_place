class Api::V1::UsersController < Api::BaseController
  before_action :authenticate_user!, except: %i[create login]
  before_action :set_user, only: %i[show update destroy]

  def index
    @users = User.includes(:profile, :traveler).all
    render json: @users, status: :ok
  end

  def show
    render json: @user, include: %i[profile traveler reviews], status: :ok
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

  def traveler
    render json: current_user,
           include: %i[traveler reviews bookings],
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
      profile_attributes: [
        :first_name,
        :last_name,
        :phone_number,
        :bio,
        :avatar_url,
        :address,
        :city,
        :state,
        :country,
        :postal_code,
        preferences: [
          :theme,
          :notification_settings,
          :privacy_settings
        ]
      ],
      traveler_attributes: [
        :preferred_currency,
        :preferred_language,
        preferences: [
          :dietary_restrictions,
          :accessibility_needs,
          :travel_style,
          :activity_preferences,
          :price_range
        ]
      ]
    )
  end
end
