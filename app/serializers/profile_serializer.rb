  # Profile attributes
  class ProfileSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :full_name, :phone_number,
               :bio, :avatar_url, :address, :city, :state, :country

    def full_name
      "#{object.first_name} #{object.last_name}"
    end
  end
