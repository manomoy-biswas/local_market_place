class ReviewSerializer < ActiveModel::Serializer
  attributes :id, :rating, :content, :verified, :created_at, :reviewer_name

  belongs_to :reviewer
  belongs_to :reviewable
  belongs_to :booking

  def reviewer_name
    object.reviewer.profile.full_name
  end
end
