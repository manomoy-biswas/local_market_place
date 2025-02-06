class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.text :bio
      t.string :avatar_url
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.decimal :latitude
      t.decimal :longitude
      t.jsonb :preferences, default: {}
      t.datetime :last_active_at

      t.timestamps

      t.index :phone_number, unique: true
      t.index %i[latitude longitude]
    end
  end
end
