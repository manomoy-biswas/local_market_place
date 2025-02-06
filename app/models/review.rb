class Review < ApplicationRecord
  belongs_to :booking
  belongs_to :reviewer, class_name: "User"
  belongs_to :reviewable, polymorphic: true

  validates :rating, presence: true, 
            inclusion: { in: 1..5 }
  validates :content, presence: true, 
            length: { minimum: 10, maximum: 1000 }
  validate :booking_completed

  scope :verified, -> { where(verified: true) }
  scope :recent, -> { order(created_at: :desc) }


  after_save :update_experience_rating
  after_destroy :update_experience_rating
  private

  def booking_completed
    unless booking.completed?
      errors.add(:booking, "must be completed before reviewing")
    end
  end

  def update_experience_rating
    booking.experience.update_rating_stats
  end
end
