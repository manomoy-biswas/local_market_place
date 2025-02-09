
class Api::V1::PaymentsController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_payment, only: %w[show refund]
  before_action :set_booking, only: %w[checkout_options verify_payment]

  def checkout_options
    render json: { errors: "Booking already paid" }, status: :unprocessable_entity and return if @booking.paid?

    payment = initiate_payment
    render json: checkout_option_response(payment), status: :ok
  end

  def verify_payment
    service = Payment::RazorpayService.new(@booking)

    if service.verify_payment(params[:razorpay_payment_id], params[:razorpay_signature])
      render json: {
               message: "Payment successful",
               booking: BookingSerializer.new(@booking)
             }, status: :ok
    else
      render json: { errors: "Payment verification failed" }, status: :unprocessable_entity
    end
  end

  def index
    @payments = current_user.booking_payments
                            .includes(:booking)
                            .order(created_at: :desc)
                            .page(params[:page])
                            .per(params[:per_page])

    render json: {
            payments: @payments,
            meta: pagination_meta(@payments)
          }, each_serializer: PaymentSerializer
  end

  def show
    render json: @payment, serializer: PaymentSerializer
  end

  def refund
    render json: { errors: "Only admin allowed" }, status: :unauthorized and return unless current_user.admin?

    if @payment.refund!(params[:reason])
      render json: {
                     message: "Payment refunded successfully",
                     payment: @payment
                   }, serializer: PaymentSerializer
    else
      render json: { errors: @payment.errors.full_messages }, 
              status: :unprocessable_entity
    end
  end

  private

  def set_payment
    @payment = Payment.find_by!(
      id: params[:id],
      booking: current_user.bookings
    )
    render json: { errors: "Payment not found" }, status: :not_found and return unless @payment
  end

  def set_booking
    @booking = Booking.find(params[:booking_id])
    render json: { errors: "Booking not found" }, status: :not_found and return unless @booking
  end

  def payment_params
    params.require(:payment).permit(
      :booking_id,
      :amount,
      :currency,
      :payment_method
    )
  end

  def initiate_payment
    service = Payment::RazorpayService.new(@booking)
    service.create_order
    @booking.payments.pending.last
  end

  def checkout_option_response(payment)
    {
      booking: {
        id: @booking.id,
        status: @booking.status,
        booking_date: @booking.booking_date,
        participants: @booking.participants
      },
      payment: {
        razorpay_order_id: payment.gateway_reference,
        amount: payment.amount,
        currency: payment.currency,
        key_id: ENV["RAZORPAY_KEY_ID"],
        name: "LocaliGo",
        description: "Booking ##{payment.booking.booking_number}",
        image: ActionController::Base.helpers.asset_path("logo.png"),
        prefill: {
          name: current_user.profile.full_name,
          email: current_user.email,
          contact: current_user.profile.phone_number
        },
        notes: {
          booking_number: @booking.booking_number,
          payment_id: payment.id
        },
        config: {
          display: {
            blocks: {
              upi: {
                name: "UPI Payment",
                instruments: [
                  { method: "upi" }
                ]
              },
              hdfc: {
                name: "Pay using HDFC Bank",
                instruments: [
                  { method: "card" },
                  { method: "netbanking" },
                  { method: "upi" }
                ]
              },
              sbi: {
                name: "Pay using SBI Bank",
                instruments: [
                  { method: "card" },
                  { method: "netbanking" },
                  { method: "upi" }
                ]
              },
              utib: { # name for AXIS block 
                name: "Pay using AXIS Bank",
                instruments: [
                  { method: "card" },
                  { method: "netbanking" },
                  { method: "upi" }
                ]
              },
              other: { #  name for other block
                name: "Other Payment modes",
                instruments: [
                  { method: "card" },
                  { method: "netbanking" },
                  { method: "wallet" }
                ]
              }
            },
            sequence: %w[block.upi block.hfdc block.sbi block.utib block.other],
            preferences: {
              show_default_blocks: false
            }
          }
        }
      }
    }
  end
end
