module Notification
  class BaseNotificationService
    def self.notify(user, template, data = {})
      new(user, template, data).send_notifications
    end

    def initialize(user, template, data)
      @user = user
      @template = template
      @data = data
    end

    private
    attr_reader :user, :template, :data
  end
end
