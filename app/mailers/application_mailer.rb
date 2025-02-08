class ApplicationMailer < ActionMailer::Base
  default from: ENV["MAILER_FROM"] || "noreply@localexperience.com"
  layout "mailer"
end
