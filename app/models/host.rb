class Host < ApplicationRecord
  # Associations
  belongs_to :user
  has_many :experiences, dependent: :restrict_with_error

  # Enums
  enum status: {
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
  validates :bank_account_number, presence: true
  validates :bank_routing_number, presence: true
  validates :bank_name, presence: true
  validates :commission_rate,
            numericality: { greater_than: 0, less_than_or_equal_to: 100 }

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
end
