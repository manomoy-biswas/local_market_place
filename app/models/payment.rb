class Payment < ApplicationRecord
  belongs_to :booking

  enum :status, {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3,
    processing_refind: 4,
    refund_failed: 5,
    refunded: 6,
    cancelled: 7
  }

  store_accessor :payment_details,
                :gateway_response,
                :payment_method_details,
                :payment_method,
                :bank_name,
                :upi_transaction_id,
                :card_network,
                :card_last4

  store_accessor :refund_details,
                :refund_status,
                :refund_speed

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true
  validates :transaction_id, uniqueness: true, allow_nil: true

  before_create :generate_transaction_id
  before_save :calculate_commission

  scope :confirmed, -> { where(status: :completed) }
  scope :pending, -> { where(status: :pending) }
  scope :processing, -> { where(status: :processing) }
  scope :failed, -> { where(status: :failed) }
  scope :refunded, -> { where(status: :refunded) }
  scope :cancelled, -> { where(status: :cancelled) }
  scope :refundable, -> { where(status: :completed).where(refunded_at: nil) }

  def payment_method_details
    case payment_method
    when "card"
      "#{card_network} card ending in #{card_last4}"
    when "upi"
      "UPI (#{upi_transaction_id})"
    when "netbanking"
      "Netbanking (#{bank_name})"
    else
      payment_method&.titleize
    end
  end

  private

  def generate_transaction_id
    self.transaction_id = "PAY#{Time.current.to_i}#{SecureRandom.hex(4).upcase}"
  end

  def calculate_commission
    return unless amount_changed?
    self.commission_amount = booking.experience.host.calculate_commission(amount)
  end
end
