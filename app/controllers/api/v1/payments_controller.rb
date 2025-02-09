
class Api::V1::PaymentsController < Api::BaseController
  before_action :authenticate_user!
  before_action :set_payment, only: %[show refund]

  def checkout_options
    
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
  end

  def payment_params
    params.require(:payment).permit(
      :booking_id,
      :amount,
      :currency,
      :payment_method
    )
  end
end
