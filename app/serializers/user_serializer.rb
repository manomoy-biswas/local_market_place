class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :role, :status, :verified, :created_at,
             :average_rating, :total_reviews

  # Associations
  has_one :profile
  has_many :reviews
  has_many :experiences, if: :is_host?
  has_many :bookings, if: :is_traveler?

  # Custom methods
  def verified
    object.verified?
  end

  def average_rating
    object.received_reviews.average(:rating).to_f.round(1)
  end

  def total_reviews
    object.received_reviews.count
  end

  private

  def is_host?
    object.host?
  end

  def is_traveler?
    object.traveler?
  end
end