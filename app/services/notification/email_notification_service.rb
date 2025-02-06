module Notification
  class EmailNotificationService < BaseNotificationService
    def send_notifications
      NotificationMailer.send(template, user, data).deliver_later
    end
  end
end
