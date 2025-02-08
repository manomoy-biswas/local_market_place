class Experience < ApplicationRecord
  include Search::Searchable

  # Relationships
  belongs_to :host, class_name: "User"
  belongs_to :category
  has_many :bookings, dependent: :restrict_with_error
  has_many :reviews, through: :bookings

  # Enums
  enum :status, {
    draft: 0,
    pending_review: 1,
    active: 2,
    paused: 3,
    cancelled: 4
  }

  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true, length: { minimum: 20, maximum: 2000 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validates :min_participants, presence: true, numericality: { greater_than: 0 }
  validates :max_participants, presence: true, 
            numericality: { greater_than: :min_participants }
  validates :address, :city, :country, presence: true

  # Geocoding
  geocoded_by :full_address
  after_validation :geocode, if: :location_changed?

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :by_price_range, ->(min, max) { where(price: min..max) }
  scope :by_location, ->(lat, lng, radius) {
    near([ lat, lng ], radius, units: :km)
  }
  scope :available_on, ->(date) {
    where("id NOT IN (
      SELECT experience_id FROM bookings 
      WHERE booking_date = ? 
      GROUP BY experience_id 
      HAVING SUM(participants) >= max_participants
    )", date)
  }

  # Methods
  def full_address
    [ address, city, state, country, postal_code ].compact.join(", ")
  end

  def average_rating
    reviews.average(:rating).to_f.round(1)
  end

  def total_reviews
    reviews.count
  end

  def available_slots(date)
    max_participants - bookings.for_date(date).sum(:participants)
  end

  def update_rating_stats
    update_columns(
      average_rating: reviews.average(:rating) || 0.0,
      total_reviews_count: reviews.count
    )
  end

  private

  def location_changed?
    saved_changes.keys.any? { |k| %w[address city state country postal_code].include?(k) }
  end
end
