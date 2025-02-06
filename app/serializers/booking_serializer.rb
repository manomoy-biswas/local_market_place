class BookingSerializer < ActiveModel::Serializer
  attributes :id, :booking_number, :booking_date, :participants, :total_amount, :status,
             :special_requests, :created_at, :cancelled_at, :cancellation_reason

  belongs_to :traveler
  belongs_to :experience
  has_one :review
  has_one :payment

  def total_amount
    object.total_amount.to_f
  end
end
