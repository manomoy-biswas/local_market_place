class Category < ApplicationRecord
  # Associations
  has_many :experiences, dependent: :restrict_with_error

  # Enums
  enum :status, { inactive: 0, active: 1 }

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, presence: true, uniqueness: true
  validates :position, presence: true, numericality: { only_integer: true }

  # Callbacks
  before_validation :generate_slug

  # Scopes
  scope :ordered, -> { order(position: :asc) }
  scope :active, -> { where(status: :active) }

  private

  def generate_slug
    self.slug ||= name.parameterize if name.present?
  end
end
