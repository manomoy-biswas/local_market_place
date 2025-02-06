class User < ApplicationRecord
  # Authentication
  has_secure_password

  # Relationships
  has_one :profile, dependent: :destroy
  has_many :experiences, foreign_key: :host_id, dependent: :destroy
  has_many :bookings, foreign_key: :traveler_id
  has_many :reviews, dependent: :destroy
  has_many :received_reviews, class_name: "Review", as: :reviewable

  # Nested attributes
  accepts_nested_attributes_for :profile

  # Enums
  enum role: { traveler: 0, host: 1, admin: 2 }
  enum status: { pending: 0, active: 1, suspended: 2 }

  # Validations
  validates :email, presence: true,
                   uniqueness: true,
                   format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 },
                      if: -> { new_record? || password.present? }

  # Callbacks
  before_validation :set_default_role, on: :create
  after_create :create_default_profile
  after_create :send_verification_email

  # Scopes
  scope :verified, -> { where.not(verified_at: nil) }
  scope :hosts, -> { where(role: :host) }
  scope :travelers, -> { where(role: :traveler) }

  def verify_email
    return if verified?
    update(verified_at: Time.current,
           verification_token: nil)
  end

  def generate_password_reset_token
    update(
      reset_password_token: SecureRandom.urlsafe_base64,
      reset_password_sent_at: Time.current
    )
  end

  private

  def set_default_role
    self.role ||= :traveler
  end

  def create_default_profile
    create_profile unless profile
  end

  def send_verification_email
    token = SecureRandom.urlsafe_base64
    update(verification_token: token)
    UserMailer.verification_email(self).deliver_later
  end
end
