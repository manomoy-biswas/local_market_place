class CreateBookings < ActiveRecord::Migration[8.0]
  def change
    create_table :bookings do |t|
      t.references :traveler, null: false, foreign_key: true
      t.references :experience, null: false, foreign_key: true
      t.date :booking_date, null: false
      t.integer :participants, null: false
      t.decimal :total_amount, precision: 10, scale: 2
      t.integer :status, default: 0
      t.string :booking_number
      t.jsonb :special_requests
      t.datetime :cancelled_at
      t.string :cancellation_reason
      t.timestamps

      t.index :booking_number, unique: true
      t.index :booking_date
      t.index :status
    end
  end
end
