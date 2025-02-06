module Notification
  class SmsNotificationService < BaseNotificationService
    def send_notifications
      TwilioClient.send_sms(
        to: user.phone_number,
        body: render_template
      )
    end

    private

    def render_template
      NotificationTemplate.new(template, data).render
    end
  end
end
