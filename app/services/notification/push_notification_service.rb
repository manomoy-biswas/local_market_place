module Notification
  class PushNotificationService < BaseNotificationService
    def send_notifications
      return unless user.push_enabled?

      FcmClient.send_notification(
        to: user.device_token,
        notification: {
          title: data[:title],
          body: data[:body]
        },
        data: data
      )
    end
  end
end
