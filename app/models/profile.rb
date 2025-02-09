class Profile < ApplicationRecord
  belongs_to :user

  # Validations
  validates :first_name, :last_name, presence: true
  validates :phone_number, presence: true,
                           uniqueness: true,
                           format: { with: /\A\+?\d{10,14}\z/ }
  validates :postal_code, format: { with: /\A\d{6}\z/ }, allow_blank: true

  store_accessor :preferences,
                 :theme,
                 :notification_settings,
                 :privacy_settings

  # Geocoding
  geocoded_by :full_address
  after_validation :geocode, if: :address_changed?

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def full_address
    [ address, city, state, country, postal_code ].compact.join(", ")
  end

  def complete?
    required_fields = [ first_name, last_name, phone_number ]
    required_fields.all?(&:present?)
  end

  private

  def address_changed?
    saved_changes.keys.any? { |k| %w[address city state country postal_code].include?(k) }
  end
end
