class HostSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id,
             :business_name,
             :tax_number,
             :business_address,
             :business_phone,
             :status,
             :identity_proof_url,
             :address_proof_url,
             :bank_details

  belongs_to :user
  has_one :profile

  def identity_proof_url
    rails_blob_url(object.identity_proof) if object.identity_proof.attached?
  end

  def address_proof_url
    rails_blob_url(object.address_proof) if object.address_proof.attached?
  end
end