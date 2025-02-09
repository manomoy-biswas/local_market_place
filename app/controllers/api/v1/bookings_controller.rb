
class Api::V1::BookingsController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_booking, only: %i[show cancel]
  before_action :check_availability, only: %i[create]

  def index
    @bookings = current_user.bookings
                            .includes(:experience)
                            .order(booking_date: :desc)
                            .page(params[:page])
                            .per(params[:per_page])

    render json: {
                   bookings: @bookings,
                   meta: pagination_meta(@bookings)
                 },
                 each_serializer: BookingSerializer
  end

  def show
    render json: @booking, serializer: BookingSerializer
  end

  def create
    ActiveRecord::Base.transaction do
      ensure_traveler_exists
      @booking = current_user.traveler.bookings.build(booking_params)
      @booking.status = :pending

      if @booking.save
        payment = initiate_payment
        render json: create_booking_response(payment), status: :created
      else
        render json: { errors: @booking.errors.full_messages },
               status: :unprocessable_entity
      end
    end
  end

  def cancel
    if @booking.cancel(params[:reason])
      render json: @booking, serializer: BookingSerializer
    else
      render json: { errors: @booking.errors.full_messages }, 
              status: :unprocessable_entity
    end
  end

  private

  def set_booking
    @booking = current_user.bookings.find(params[:id])
  end

  def booking_params
    params.require(:booking).permit(
      :experience_id,
      :booking_date,
      :participants,
      :special_requests
    )
  end

  def check_availability
    experience = Experience.find(booking_params[:experience_id])
    unless experience.available?(
      Date.parse(booking_params[:booking_date]),
      booking_params[:participants]
    )
      render json: { error: "No availability for selected date/participants" },
             status: :unprocessable_entity
    end
  end

  def ensure_traveler_exists
    return if current_user.traveler.present?

    current_user.create_traveler!
  end

  def create_booking_response(payment)
    {
      booking: BookingSerializer.new(@booking),
      payment: {
        razorpay_order_id: payment.gateway_reference,
        amount: payment.amount,
        currency: payment.currency,
        key_id: ENV["RAZORPAY_KEY_ID"],
        prefill: {
          name: current_user.profile.full_name,
          email: current_user.email,
          contact: current_user.profile.phone_number
        },
        notes: {
          booking_number: @booking.booking_number
        }
      }
    }
  end

  def initiate_payment
    service = Payment::RazorpayService.new(@booking)
    service.create_order
    @booking.payments.pending.last
  end
end
