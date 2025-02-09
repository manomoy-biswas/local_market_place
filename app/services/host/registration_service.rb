class Host::RegistrationService
  attr_reader :errors

  def initialize(user, params)
    @user = user
    @params = params
    @errors = []
  end

  def call
    return false unless can_become_host?

    ActiveRecord::Base.transaction do
      create_host_profile
      update_user_role
      # schedule_verification
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    @errors = e.record.errors.full_messages
    false
  end

  private

  def can_become_host?
    return true if @user.profile&.complete?

    @errors << "Please complete your profile first"
    false
  end

  def create_host_profile
      @host = @user.create_host!(
        business_name: @params[:business_name],
        tax_number: @params[:tax_number], # GST number for India
        business_phone: @params[:business_phone],
        business_address: @params[:business_address],
        bank_details: {
          account_holder_name: @params[:account_holder_name],
          account_number: @params[:bank_account_number],
          ifsc_code: @params[:ifsc_code],
          bank_name: @params[:bank_name],
          bank_branch: @params[:bank_branch],
          account_type: @params[:account_type]
        },
        status: :pending,
        commission_rate: Host::DEFAULT_COMMISSION_RATE
      )
  end

  def update_user_role
    @user.update!(role: :host)
  end

  def schedule_verification
    HostVerificationJob.perform_later(@host)
    AdminNotificationJob.perform_later(
      "New Host Registration",
      "#{@host.business_name} has registered as a host"
    )
  end
end
