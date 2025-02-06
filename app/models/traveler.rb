class Traveler < ApplicationRecord
  belongs_to :user
  has_many :bookings, dependent: :restrict_with_error
  has_many :experiences, through: :bookings
  has_many :reviews, through: :bookings

  validates :preferred_currency, presence: true

  store_accessor :preferences, :dietary_restrictions, :accessibility_needs
 
  scope :active, -> { joins(:user).where(users: { status: :active }) }
end
