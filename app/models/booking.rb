class Booking < ApplicationRecord
  belongs_to :traveler
  belongs_to :experience
  has_one :review, dependent: :destroy
  has_one :payment, dependent: :restrict_with_error

  enum status: {
    pending: 0,
    confirmed: 1,
    completed: 2,
    cancelled: 3,
    refunded: 4
  }

  validates :booking_date, :participants, presence: true
  validates :participants, numericality: { 
    greater_than: 0,
    less_than_or_equal_to: ->(booking) { booking.experience.max_participants }
  }

  before_create :generate_booking_number
  before_save :calculate_total_amount

  scope :upcoming, -> { where("booking_date > ?", Date.today) }
  scope :past, -> { where("booking_date < ?", Date.today) }

  private

  def generate_booking_number
    self.booking_number = "LMPBK#{Time.current.to_i}#{SecureRandom.hex(3).upcase}"
  end

  def calculate_total_amount
    self.total_amount = experience.price * participants
  end
end
