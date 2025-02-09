class Payment::RazorpayService
  def initialize(booking)
    @booking = booking
    @payment = @booking.payments.pending.last
    @amount = (@booking.total_amount * 100).to_i # Convert to paise
  end

  def create_order
    order = Razorpay::Order.create(
      amount: @amount,
      currency: @payment.currency,
      receipt: @booking.booking_number,
      notes: {
        booking_id: @booking.id,
        payment_id: @payment.id,
        user_email: @booking.traveler.user.email
      }
    )

    @payment.update(gateway_reference: order.id)
    order
  end

  def verify_payment(payment_id, signature)
    razorpay_payment = Razorpay::Payment.fetch(payment_id)

    if razorpay_payment.order_id == @payment.gateway_reference
      if verify_signature(payment_id, signature)
        process_successful_payment(razorpay_payment)
        return true
      end
    end

    process_failed_payment
    false
  end

  def refund(reason)
    return false unless @payment.completed?
    return false if refund_window_expired?

    begin
      @payment.update!(status: :processing_refund)
      refund = Razorpay::Payment.fetch(@payment.transaction_id).refund({
        notes: {
          booking_id: @booking.id,
          payment_id: @payment.id,
          reason: reason
        }
      })
      process_successful_refund(refund, reason)
      true
    rescue Razorpay::Error => e
      process_failed_refund(e.message)
      false
    end
  end

  private

  def verify_signature(payment_id, signature)
    Razorpay::Utility.verify_payment_signature({
      "razorpay_order_id" => @payment.gateway_reference,
      "razorpay_payment_id" => payment_id,
      "razorpay_signature" => signature
    })
  rescue Razorpay::Error
    false
  end

  def process_successful_payment(razorpay_payment)
    @payment.update!(
      transaction_id: razorpay_payment.id,
      payment_method: razorpay_payment.method,
      amount: razorpay_payment.amount / 100.0,
      currency: razorpay_payment.currency,
      status: :completed,
      paid_at: Time.current,
      payment_details: razorpay_payment.to_h
    )
    @booking.confirm!
  end

  def process_failed_payment
    @payment.update!(
      status: :failed,
      error_message: "Payment verification failed"
    )
    @booking.cancel!
  end

  def process_successful_refund(refund, reason)
    Payment.transaction do
      @payment.update!(
        status: :refunded,
        refunded_at: Time.current,
        refund_reason: reason,
        refund_id: refund.id,
        refund_details: refund.to_h
      )
      @booking.refund!
    end
  end

  def process_failed_refund(error_message)
    @payment.update!(
      status: :refund_failed,
      error_message: error_message
    )
  end

  def refund_window_expired?
    @booking.booking_date < 72.hours.ago
  end
end
