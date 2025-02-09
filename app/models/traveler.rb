class Traveler < ApplicationRecord
  belongs_to :user
  has_many :bookings, dependent: :restrict_with_error
  has_many :payments, through: :bookings
  has_many :experiences, through: :bookings
  has_many :reviews, through: :bookings

  # constants
  DEFAULT_CURRENCY = "INR".freeze
  SUPPORTED_CURRENCIES = %w[USD EUR GBP INR].freeze

  # Validations
  validates :preferred_currency, 
            presence: true,
            inclusion: { in: SUPPORTED_CURRENCIES }

  # Callbacks
  before_validation :set_default_currency, on: :create

  store_accessor :preferences,
                 :dietary_restrictions,
                 :accessibility_needs,
                 :travel_style,
                 :activity_preferences,
                 :price_range
 
  scope :active, -> { joins(:user).where(users: { status: :active }) }

  private

  def set_default_currency
    self.preferred_currency ||= DEFAULT_CURRENCY
  end
end
