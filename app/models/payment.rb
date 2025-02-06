class Payment < ApplicationRecord
  belongs_to :booking

  enum status: {
    pending: 0,
    processing: 1,
    completed: 2,
    failed: 3,
    refunded: 4,
    cancelled: 5
  }

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_id, uniqueness: true, allow_nil: true

  before_create :generate_transaction_id
  before_save :calculate_commission

  scope :successful, -> { where(status: :completed) }
  scope :refundable, -> { where(status: :completed).where(refunded_at: nil) }

  def process_payment
    PaymentService.process(self)
  end

  def refund!(reason)
    PaymentService.refund(self, reason)
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
