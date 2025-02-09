class Host < ApplicationRecord
  # Associations
  belongs_to :user
  has_one :profile, through: :user
  has_many :experiences, dependent: :restrict_with_error

  # Constants for Indian banking
  INDIAN_BANK_CODES = {
    format: /\A[A-Z]{4}0[A-Z0-9]{6}\z/,
    name: "IFSC Code"
  }.freeze
  DEFAULT_COMMISSION_RATE = 15.0
  MINIMUM_COMMISION_RATE = 5.0
  MAXIMUM_COMMISION_RATE = 25.0

  # Enums
  enum :status, {
    pending: 0,
    under_review: 1,
    approved: 2,
    suspended: 3,
    rejected: 4
  }

  # Validations
  validates :business_name, presence: true, uniqueness: true
  validates :tax_number, presence: true, uniqueness: true
  validates :business_address, presence: true
  validates :business_phone, presence: true
  validates :bank_name, presence: true
  validates :commission_rate,
            numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validate :validate_indian_bank_details, if: :bank_details_present?

  # Add validation for account_type
  validates :account_type,
            inclusion: {
              in: %w[savings current],
              message: "must be either savings or current"
            },
            if: -> { bank_details.present? }

  # Attachments
  has_one_attached :identity_proof
  has_one_attached :address_proof

  # Callbacks
  after_create :schedule_verification

  # Geocoding
  geocoded_by :business_address
  after_validation :geocode, if: :business_address_changed?
  # Store bank details securely
  store_accessor :bank_details,
                :account_holder_name,
                :bank_name,
                :bank_branch,
                :ifsc_code,
                :account_type

  # Scopes
  scope :verified, -> { where.not(verified_at: nil) }
  scope :active, -> { where(status: :approved) }

  # Methods
  def verified?
    verified_at.present?
  end

  def calculate_commission(amount)
    (amount * commission_rate / 100).round(2)
  end

  def verify!
    update!(
      verified_at: Time.current,
      status: :approved
    )
  end

  private

  def documents_present?
    identity_proof.present? && address_proof.present?
  end

  def validate_indian_bank_details
    return unless bank_details.present?

    errors.add(:account_type, "must be either savings or current") unless bank_details["account_type"].in?(%w[savings current])
    errors.add(:account_holder_name, "can't be blank") if bank_details["account_holder_name"].blank?
    errors.add(:ifsc_code, "must be a valid IFSC code") unless bank_details["ifsc_code"].match?(INDIAN_BANK_CODES[:format])
    errors.add(:account_number, "must be between 9 and 18 digits") unless bank_details["account_number"].match?(/\A\d{9,18}\z/)
  end

  def bank_details_present?
    bank_details.present? && status.in?(%w[pending under_review])
  end

  def schedule_verification
    # HostVerificationJob.perform_later(self)
    # AdminNotificationJob.perform_later(
    #   "New Host Registration",
    #   "#{business_name} has registered as a host"
    # )
  end
end
