class CreateTravelers < ActiveRecord::Migration[8.0]
  def change
    create_table :travelers do |t|
      t.references :user, null: false, foreign_key: true
      t.jsonb :preferences, default: {}
      t.integer :trips_count, default: 0
      t.string :preferred_language
      t.string :preferred_currency, default: "INR"
      t.timestamps

      t.index :preferences, using: :gin
    end
  end
end
