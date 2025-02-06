# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_02_06_204033) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.bigint "traveler_id", null: false
    t.bigint "experience_id", null: false
    t.date "booking_date", null: false
    t.integer "participants", null: false
    t.decimal "total_amount", precision: 10, scale: 2
    t.integer "status", default: 0
    t.string "booking_number"
    t.jsonb "special_requests"
    t.datetime "cancelled_at"
    t.string "cancellation_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_date"], name: "index_bookings_on_booking_date"
    t.index ["booking_number"], name: "index_bookings_on_booking_number", unique: true
    t.index ["experience_id"], name: "index_bookings_on_experience_id"
    t.index ["status"], name: "index_bookings_on_status"
    t.index ["traveler_id"], name: "index_bookings_on_traveler_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.string "icon"
    t.string "image"
    t.integer "status", default: 0
    t.integer "position"
    t.integer "experiences_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_categories_on_position"
    t.index ["slug"], name: "index_categories_on_slug", unique: true
    t.index ["status"], name: "index_categories_on_status"
  end

  create_table "experiences", force: :cascade do |t|
    t.bigint "host_id", null: false
    t.string "title", null: false
    t.text "description", null: false
    t.integer "status", default: 0
    t.bigint "category_id", null: false
    t.string "tags", default: [], array: true
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "currency", default: "INR"
    t.integer "duration_minutes", null: false
    t.integer "min_participants", default: 1
    t.integer "max_participants"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "cover_image"
    t.string "images", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "average_rating", precision: 3, scale: 2, default: "0.0"
    t.integer "total_reviews_count", default: 0
    t.index "to_tsvector('english'::regconfig, (((title)::text || ' '::text) || description))", name: "experiences_text_search", using: :gin
    t.index ["average_rating"], name: "index_experiences_on_average_rating"
    t.index ["category_id"], name: "index_experiences_on_category_id"
    t.index ["city"], name: "index_experiences_on_city"
    t.index ["host_id"], name: "index_experiences_on_host_id"
    t.index ["latitude", "longitude"], name: "index_experiences_on_latitude_and_longitude"
    t.index ["price"], name: "index_experiences_on_price"
    t.index ["status"], name: "index_experiences_on_status"
    t.index ["tags"], name: "index_experiences_on_tags", using: :gin
  end

  create_table "hosts", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "business_name"
    t.string "tax_number"
    t.string "business_address"
    t.string "business_phone"
    t.string "website"
    t.string "bank_account_number"
    t.string "bank_routing_number"
    t.string "bank_name"
    t.string "identity_proof"
    t.string "address_proof"
    t.decimal "commission_rate", precision: 5, scale: 2, default: "10.0"
    t.datetime "verified_at"
    t.integer "status", default: 0
    t.jsonb "verification_details", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_name"], name: "index_hosts_on_business_name"
    t.index ["status"], name: "index_hosts_on_status"
    t.index ["user_id"], name: "index_hosts_on_user_id"
    t.index ["verified_at"], name: "index_hosts_on_verified_at"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "sender_id", null: false
    t.bigint "recipient_id", null: false
    t.bigint "booking_id"
    t.text "content", null: false
    t.datetime "read_at"
    t.boolean "is_system_message", default: false
    t.string "message_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_messages_on_booking_id"
    t.index ["message_type"], name: "index_messages_on_message_type"
    t.index ["read_at"], name: "index_messages_on_read_at"
    t.index ["recipient_id"], name: "index_messages_on_recipient_id"
    t.index ["sender_id", "recipient_id"], name: "index_messages_on_sender_id_and_recipient_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.decimal "commission_amount", precision: 10, scale: 2
    t.string "currency", default: "INR"
    t.integer "status", default: 0
    t.string "payment_method"
    t.string "transaction_id"
    t.string "gateway_reference"
    t.jsonb "payment_details"
    t.datetime "paid_at"
    t.datetime "refunded_at"
    t.string "refund_reason"
    t.string "error_message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["gateway_reference"], name: "index_payments_on_gateway_reference"
    t.index ["paid_at"], name: "index_payments_on_paid_at"
    t.index ["status"], name: "index_payments_on_status"
    t.index ["transaction_id"], name: "index_payments_on_transaction_id", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.text "bio"
    t.string "avatar_url"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "country"
    t.string "postal_code"
    t.decimal "latitude"
    t.decimal "longitude"
    t.jsonb "preferences", default: {}
    t.datetime "last_active_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["latitude", "longitude"], name: "index_profiles_on_latitude_and_longitude"
    t.index ["phone_number"], name: "index_profiles_on_phone_number", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.bigint "booking_id", null: false
    t.bigint "reviewer_id", null: false
    t.string "reviewable_type"
    t.bigint "reviewable_id"
    t.integer "rating", null: false
    t.text "content"
    t.boolean "verified", default: false
    t.datetime "verified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_reviews_on_booking_id"
    t.index ["rating"], name: "index_reviews_on_rating"
    t.index ["reviewable_type", "reviewable_id"], name: "index_reviews_on_reviewable"
    t.index ["reviewer_id"], name: "index_reviews_on_reviewer_id"
    t.index ["verified"], name: "index_reviews_on_verified"
  end

  create_table "travelers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.jsonb "preferences", default: {}
    t.integer "trips_count", default: 0
    t.string "preferred_language"
    t.string "preferred_currency", default: "INR"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["preferences"], name: "index_travelers_on_preferences", using: :gin
    t.index ["user_id"], name: "index_travelers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer "role", default: 0
    t.integer "status", default: 0
    t.string "verification_token"
    t.datetime "verification_sent_at"
    t.datetime "verified_at"
    t.string "provider"
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["verification_token"], name: "index_users_on_verification_token", unique: true
  end

  add_foreign_key "bookings", "experiences"
  add_foreign_key "bookings", "travelers"
  add_foreign_key "experiences", "categories"
  add_foreign_key "experiences", "users", column: "host_id"
  add_foreign_key "hosts", "users"
  add_foreign_key "messages", "bookings"
  add_foreign_key "messages", "users", column: "recipient_id"
  add_foreign_key "messages", "users", column: "sender_id"
  add_foreign_key "payments", "bookings"
  add_foreign_key "profiles", "users"
  add_foreign_key "reviews", "bookings"
  add_foreign_key "reviews", "users", column: "reviewer_id"
  add_foreign_key "travelers", "users"
end
