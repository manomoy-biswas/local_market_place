
class Api::V1::ReviewsController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_review, only: [:show, :update, :destroy]
  before_action :check_review_eligibility, only: [:create]

  def index
    @reviews = Review.includes(:reviewer, :reviewable)
                    .where(reviewable_type: params[:reviewable_type],
                          reviewable_id: params[:reviewable_id])
                    .page(params[:page])

    render json: @reviews, 
            each_serializer: ReviewSerializer,
            meta: pagination_dict(@reviews)
  end

  def show
    render json: @review, serializer: ReviewSerializer
  end

  def create
    @review = current_user.reviews.build(review_params)

    if @review.save
      render json: @review, 
              status: :created, 
              serializer: ReviewSerializer
    else
      render json: { errors: @review.errors.full_messages }, 
              status: :unprocessable_entity
    end
  end

  def update
    if @review.update(review_params)
      render json: @review, serializer: ReviewSerializer
    else
      render json: { errors: @review.errors.full_messages }, 
              status: :unprocessable_entity
    end
  end

  def destroy
    @review.destroy
    head :no_content
  end

  private

  def set_review
    @review = current_user.reviews.find(params[:id])
  end

  def review_params
    params.require(:review).permit(
      :booking_id,
      :rating,
      :content,
      :reviewable_type,
      :reviewable_id
    )
  end

  def check_review_eligibility
    booking = Booking.find(review_params[:booking_id])
    unless booking.completed? && booking.traveler_id == current_user.id
      render json: { error: "Not eligible to review this booking" },
              status: :forbidden
    end
  end
end
