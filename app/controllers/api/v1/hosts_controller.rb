
class Api::V1::HostsController < Api::BaseController
  before_action :authenticate_user!
  before_action :check_eligibility, only: %i[create]

  def create
    service = Host::RegistrationService.new(current_user, host_params)

    if service.call
      render json: current_user.host,
              status: :created
    else
      render json: { errors: service.errors },
              status: :unprocessable_entity
    end
  end

  def show
    render json: current_user.host, serializer: HostSerializer
  end

  private

  def host_params
    params.require(:host).permit(
      :business_name,
      :tax_number,
      :business_address,
      :business_phone,
      :identity_proof,
      :address_proof,
      :account_holder_name,
      :bank_account_number,
      :ifsc_code,
      :bank_name,
      :bank_branch,
      :account_type
    )
  end

  def check_eligibility
    unless current_user.profile&.complete?
      render json: {
        error: "Please complete your profile before becoming a host"
      }, status: :unprocessable_entity
    end
  end
end
