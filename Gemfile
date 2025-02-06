source "https://rubygems.org"

# API serialization
gem "active_model_serializers"
# File Storage
gem 'aws-sdk-s3'
# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt"
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
# storage
gem 'cloudinary'
# Authentication
gem "devise"
# push notifications
gem "fcm"
# Env variables
gem "figaro"
# Geocoding
gem "geocoder"
# location Service
gem 'google_maps_service'
# JWT token authentication
gem "jwt"
# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false
# pagination
gem "kaminari"
# oauth authentication
gem "oauth2"
# payment getway
gem "paypal-sdk-rest"
# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"
# Search
gem "pg_search"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"
# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
#API Development
gem 'rack-cors'
gem "redis"
gem "rails", "~> 8.0.1"
# API documentation
gem "rswag"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"
# email provider
gem 'sendgrid-ruby'
# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cable"
gem "solid_cache"
gem "solid_queue"
# Payment processing
gem "stripe"

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false
# sms notifications
gem "twilio-ruby"
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]




# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
  gem "letter_opener"
  gem "bullet"
end
