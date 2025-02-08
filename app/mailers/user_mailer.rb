class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @verification_url = verify_email_url(@user.verification_token)

    mail(
      to: @user.email,
      subject: "Verify your Local Experience account"
    )
  end

  def welcome_email(user)
    @user = user
    @login_url = login_url

    mail(
      to: @user.email,
      subject: "Welcome to Local Experience"
    )
  end

  def reset_password_email(user, token)
    @user = user
    @reset_url = reset_password_url(token)

    mail(
      to: @user.email,
      subject: "Reset your password"
    )
  end

  def booking_confirmation(booking)
    @booking = booking
    @user = booking.traveler.user

    mail(
      to: @user.email,
      subject: "Booking Confirmation ##{booking.booking_number}"
    )
  end

  def experience_reminder(booking)
    @booking = booking
    @user = booking.traveler.user

    mail(
      to: @user.email,
      subject: "Reminder: Your experience is tomorrow!"
    )
  end

  private

  def verify_email_url(token)
    "#{ENV["FRONTEND_URL"]}/verify-email?token=#{token}"
  end

  def reset_password_url(token)
    "#{ENV["FRONTEND_URL"]}/reset-password?token=#{token}"
  end

  def login_url
    "#{ENV["FRONTEND_URL"]}/login"
  end
end
