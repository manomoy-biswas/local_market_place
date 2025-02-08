class User < ApplicationRecord
  # Authentication
  has_secure_password

  # Relationships
  has_one :profile, dependent: :destroy
  has_many :experiences, foreign_key: :host_id, dependent: :destroy
  has_many :bookings, foreign_key: :traveler_id
  has_many :reviews, foreign_key: :reviewer_id, dependent: :destroy
  has_many :received_reviews, class_name: "Review", as: :reviewable

  # Nested attributes
  accepts_nested_attributes_for :profile

  # Enums
  enum :role, { traveler: 0, host: 1, admin: 2 }, default: :traveler
  enum :status, { pending: 0, active: 1, suspended: 2 }, default: :pending

  # Validations
  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :status, presence: true, inclusion: { in: statuses.keys }
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

  def verify_email(token)
    return false unless verification_token == token

    return false if verification_expired?

    update(
      verified_at: Time.current,
      verification_token: nil
    )
  end

  def generate_password_reset_token
    update(
      reset_password_token: SecureRandom.urlsafe_base64,
      reset_password_sent_at: Time.current
    )
  end

  def role?(role_name)
    role == role_name.to_s
  end

  def status?(status_name)
    status == status_name.to_s
  end

  def verified?
    verified_at.present?
  end

  def verification_pending?
    !verified? && verification_token.present?
  end

  def verification_expired?
    verification_pending? && verification_sent_at < 24.hours.ago
  end

  # Authentication methods
  def authenticate(password)
    return false unless password_digest.present?

    BCrypt::Password.new(password_digest).is_password?(password)
  end

  def self.authenticate(email, password)
    user = find_by(email: email.downcase)
    return nil unless user

    return user if authenticate(password)
    nil
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def set_default_role
    self.role ||= :traveler
  end

  def create_default_profile
    create_profile unless profile
  end

  def send_verification_email
    update(verification_token: generate_unique_token, verification_sent_at: Time.current)
    UserMailer.verification_email(self).deliver_later
  end

  def generate_unique_token
    # Version prefix for future token format changes
    version = "v1"
    # Components for token
    timestamp = Time.current.to_i
    random = SecureRandom.hex(8)
    user_component = id || SecureRandom.hex(4)
    # Combine components
    raw_token = "#{version}:#{user_component}:#{timestamp}:#{random}"
    # Add checksum and encode
    checksum = Digest::SHA256.hexdigest(raw_token)[0..7]
    Base64.urlsafe_encode64("#{raw_token}:#{checksum}")
  end
end
