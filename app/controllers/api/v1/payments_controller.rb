module Api
  module V1
    class PaymentsController < BaseController
      before_action :authenticate_user!
      before_action :set_payment, only: [:show, :refund]

      def index
        @payments = current_user.payments
                              .includes(:booking)
                              .order(created_at: :desc)
                              .page(params[:page])

        render json: @payments, 
               each_serializer: PaymentSerializer,
               meta: pagination_dict(@payments)
      end

      def show
        render json: @payment, serializer: PaymentSerializer
      end

      def create
        @payment = Payment.new(payment_params)

        if @payment.save
          ProcessPaymentJob.perform_later(@payment)
          render json: @payment, 
                 status: :created, 
                 serializer: PaymentSerializer
        else
          render json: { errors: @payment.errors.full_messages }, 
                 status: :unprocessable_entity
        end
      end

      def refund
        if @payment.refund!(params[:reason])
          render json: @payment, serializer: PaymentSerializer
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
  end
end
