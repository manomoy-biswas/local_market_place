class Payment::PaymentService
  def self.refund(payment, reason)
    new(payment).refund(reason)
  end

  def initialize(payment)
    @payment = payment
    @booking = payment.booking
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

  def notify_refund
    NotificationService.refund_processed(payment)
  end

  def refund_window_expired?
    booking.booking_date > 72.hours.ago
  end

  def handle_refund_error(error)
    Rails.logger.error("Refund failed: #{error.message}")
  end
end
