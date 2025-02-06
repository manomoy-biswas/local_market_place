class ExperienceSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :price, :currency, :duration_minutes,
             :min_participants, :max_participants, :status, :average_rating,
             :total_reviews, :location_details, :images, :cover_image, :tags

  belongs_to :host
  belongs_to :category
  has_many :reviews, serializer: ReviewSerializer

  def average_rating
    object.average_rating
  end

  def total_reviews
    object.total_reviews
  end

  def location_details
    {
      address: object.address,
      city: object.city,
      state: object.state,
      country: object.country,
      postal_code: object.postal_code,
      latitude: object.latitude,
      longitude: object.longitude
    }
  end
end
