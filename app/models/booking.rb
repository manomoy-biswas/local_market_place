class Booking < ApplicationRecord
  belongs_to :traveler, class_name: "User"
  belongs_to :experience
  has_one :review, dependent: :destroy
  has_one :payment, dependent: :restrict_with_error

  enum :status, {
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

  scope :for_date, ->(date) { where(booking_date: date) }
  scope :upcoming, -> { where("booking_date > ?", Date.today) }
  scope :past, -> { where("booking_date < ?", Date.today) }
  scope :pending, -> { where(status: :pending) }
  scope :confirmed, -> { where(status: :confirmed) }
  scope :completed, -> { where(status: :completed) }
  scope :cancelled, -> { where(status: :cancelled) }
  scope :refunded, -> { where(status: :refunded) }

  {
    pending: :pending,
    confirmed: :confirm,
    completed: :complete,
    cancelled: :cancel,
    refunded: :refund
  }.each do |status_key, method_name|
    # Define status change method (e.g., confirm!, cancel!)
    define_method "#{method_name}!" do
      update!(status: status_key)
    end

    # Define status check method (e.g., confirmed?, cancelled?)
    define_method "#{status_key}?" do
      status == status_key
    end
  end

  private

  def generate_booking_number
    self.booking_number = "LMPBK#{Time.current.to_i}#{SecureRandom.hex(3).upcase}"
  end

  def calculate_total_amount
    self.total_amount = experience.price * participants
  end
end
