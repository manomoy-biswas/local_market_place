app/
├── controllers/
│   ├── api/
│   │   ├── v1/
│   │   │   ├── experiences_controller.rb Done
│   │   │   ├── bookings_controller.rb done
│   │   │   ├── users_controller.rb Done
│   │   │   ├── reviews_controller.rb done
│   │   │   ├── messages_controller.rb done
│   │   │   └── payments_controller.rb done
│   │   └── base_controller.rb Done
│   └── application_controller.rb Done
├── models/
│   ├── user.rb Done
│   ├── host.rb Done
│   ├── traveler.rb Done
│   ├── experience.rb Done
│   ├── booking.rb Done
│   ├── review.rb Done
│   ├── message.rb done
│   ├── payment.rb done
│   └── category.rb Done
├── services/
│   ├── authentication/ Done
│   ├── payment/ done
│   ├── notification/ done
│   └── search/
├── serializers/
│   ├── user_serializer.rb Done
│   ├── experience_serializer.rb Done
│   ├── booking_serializer.rb Done
│   └── review_serializer.rb Done
└── jobs/
    ├── booking_reminder_job.rb
    ├── payment_processing_job.rb
    └── notification_delivery_job.rb