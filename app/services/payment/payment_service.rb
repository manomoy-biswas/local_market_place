module Payment
  class PaymentService
    def self.process(payment)
      new(payment).process
    end

    def self.refund(payment, reason)
      new(payment).refund(reason)
    end

    def initialize(payment)
      @payment = payment
      @booking = payment.booking
    end

    def process
      ActiveRecord::Base.transaction do
        begin
          validate_payment
          create_stripe_payment
          update_payment_status
          notify_participants
          true
        rescue StandardError => e
          handle_payment_error(e)
          false
        end
      end
    end

    def refund(reason)
      ActiveRecord::Base.transaction do
        begin
          validate_refund
          process_stripe_refund
          update_refund_status(reason)
          notify_refund
          true
        rescue StandardError => e
          handle_refund_error(e)
          false
        end
      end
    end

    private

    attr_reader :payment, :booking

    def validate_payment
      raise PaymentError, "Invalid payment amount" unless valid_amount?
      raise PaymentError, "Payment already processed" if payment.completed?
      raise PaymentError, "Booking is not confirmed" unless booking.confirmed?
    end

    def create_stripe_payment
      stripe_payment = Stripe::PaymentIntent.create(
        amount: (payment.amount * 100).to_i,
        currency: payment.currency.downcase,
        payment_method: payment.payment_method,
        metadata: {
          booking_id: booking.id,
          transaction_id: payment.transaction_id
        }
      )
      payment.update!(gateway_reference: stripe_payment.id)
    end

    def update_payment_status
      payment.update!(
        status: :completed,
        paid_at: Time.current,
        payment_details: {
          gateway: "stripe",
          payment_method_details: payment.payment_method
        }
      )
      booking.update!(status: :confirmed)
    end

    def validate_refund
      raise RefundError, "Payment not completed" unless payment.completed?
      raise RefundError, "Payment already refunded" if payment.refunded?
      raise RefundError, "Refund window expired" if refund_window_expired?
    end

    def process_stripe_refund
      Stripe::Refund.create(
        payment_intent: payment.gateway_reference,
        metadata: {
          reason: reason,
          booking_id: booking.id
        }
      )
    end

    def update_refund_status(reason)
      payment.update!(
        status: :refunded,
        refunded_at: Time.current,
        refund_reason: reason
      )
      booking.update!(status: :refunded)
    end

    def notify_participants
      NotificationService.payment_completed(payment)
    end

    def notify_refund
      NotificationService.refund_processed(payment)
    end

    def valid_amount?
      payment.amount == booking.total_amount
    end

    def refund_window_expired?
      booking.booking_date > 24.hours.ago
    end

    def handle_payment_error(error)
      payment.update!(
        status: :failed,
        error_message: error.message
      )
      Rails.logger.error("Payment failed: #{error.message}")
      notify_payment_failure(error)
    end

    def handle_refund_error(error)
      Rails.logger.error("Refund failed: #{error.message}")
      notify_refund_failure(error)
    end
  end
end
