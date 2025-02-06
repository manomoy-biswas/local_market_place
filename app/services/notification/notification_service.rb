module Notification
  class NotificationService
    TEMPLATES = {
      booking_confirmed: "booking_confirmed",
      payment_completed: "payment_completed",
      booking_reminder: "booking_reminder",
      review_reminder: "review_reminder"
    }.freeze

    class << self
      def booking_confirmed(booking)
        notify_user(booking.traveler.user, :booking_confirmed, booking_data(booking))
      end

      def payment_completed(payment)
        notify_user(payment.booking.traveler.user, :payment_completed, payment_data(payment))
      end

      def booking_reminder(booking)
        notify_user(booking.traveler.user, :booking_reminder, booking_data(booking))
      end

      def review_reminder(booking)
        notify_user(booking.traveler.user, :review_reminder, booking_data(booking))
      end

      private

      def notify_user(user, template, data)
        [
          EmailNotificationService,
          SmsNotificationService,
          PushNotificationService
        ].each { |service| service.notify(user, TEMPLATES[template], data) }
      end

      def booking_data(booking)
        {
          booking_number: booking.booking_number,
          experience_title: booking.experience.title,
          date: booking.booking_date
        }
      end

      def payment_data(payment)
        {
          amount: payment.amount,
          currency: payment.currency,
          transaction_id: payment.transaction_id
        }
      end
    end
  end
end
