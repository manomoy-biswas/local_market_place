class Message < ApplicationRecord
  belongs_to :sender, class_name: "User"
  belongs_to :recipient, class_name: "User"
  belongs_to :booking, optional: true

  validates :content, presence: true
  validates :sender, presence: true
  validates :recipient, presence: true

  enum message_type: {
    direct: "direct",
    booking: "booking",
    system: "system"
  }

  scope :unread, -> { where(read_at: nil) }
  scope :between_users, ->(user1_id, user2_id) {
    where(sender_id: [user1_id, user2_id], 
          recipient_id: [user1_id, user2_id])
  }

  after_create :send_notification

  def mark_as_read!
    update!(read_at: Time.current) if read_at.nil?
  end

  private

  def send_notification
    NotificationService.new_message(self)
  end
end
