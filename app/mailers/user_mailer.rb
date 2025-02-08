class UserMailer < ApplicationMailer
  def verification_email(user)
    @user = user
    @verification_url = verify_email_url(@user.verification_token)
    @content = role_specific_verification_content

    mail(
      to: @user.email,
      subject: "Verify your Local Experience #{@user.role.titleize} account"
    )
  end

  def welcome_email(user)
    @user = user
    @login_url = login_url
    @content = role_specific_welcome_content

    mail(
      to: @user.email,
      subject: welcome_subject
    )
  end

  def reset_password_email(user)
    @user = user
    @reset_url = reset_password_url(@user.reset_password_token)

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

  def role_specific_verification_content
    case @user.role
    when "host"
      {
        title: "Welcome Future Experience Host!",
        message: "Start your journey as a host by verifying your email.",
        next_steps: ["Complete host verification", "Create your first experience", "Set up payout details"]
      }
    when "traveler"
      {
        title: "Welcome Adventurer!",
        message: "Your journey begins with email verification.",
        next_steps: ["Complete your profile", "Browse experiences", "Book your first adventure"]
      }
    when "admin"
      {
        title: "Welcome Administrator!",
        message: "Verify your email to access admin controls.",
        next_steps: ["Set up your admin profile", "Review pending hosts", "Monitor platform metrics"]
      }
    end
  end

  def role_specific_welcome_content
    case @user.role
    when "host"
      {
        title: "Ready to Host Experiences!",
        features: [ "Host Dashboard", "Experience Management", "Booking Calendar" ],
        cta: "Create Your First Experience"
      }
    when "traveler"
      {
        title: "Ready for Adventure!",
        features: [ "Personalized Recommendations", "Booking Management", "Review System" ],
        cta: "Explore Experiences"
      }
    when "admin"
      {
        title: "Welcome to Admin Dashboard",
        features: [ "User Management", "Content Moderation", "Analytics Dashboard" ],
        cta: "Access Admin Panel"
      }
    end
  end

  def welcome_subject
    case @user.role
    when "host"
      "Welcome to Local Experience - Start Hosting!"
    when "traveler"
      "Welcome to Local Experience - Start Exploring!"
    when "admin"
      "Welcome to Local Experience - Admin Access"
    end
  end

  def verify_email_url(token)
    "#{ENV["host_url"]}/verify-email/#{token}"
  end

  def reset_password_url(token)
    "#{ENV["host_url"]}/reset-password/#{token}"
  end

  def login_url
    "#{ENV["host_url"]}/login"
  end
end
