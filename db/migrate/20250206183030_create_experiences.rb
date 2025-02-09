class CreateExperiences < ActiveRecord::Migration[8.0]
  def change
    create_table :experiences do |t|
      # Basic info
      t.references :host, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description, null: false
      t.integer :status, default: 0

      # Categorization
      t.references :category, null: false, foreign_key: true
      t.string :tags, array: true, default: []

      # Pricing
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :currency, default: "INR"
      t.integer :duration_minutes, null: false

      # Capacity
      t.integer :min_participants, default: 1
      t.integer :max_participants

      # Location
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :postal_code
      t.decimal :latitude
      t.decimal :longitude

      # Media
      t.string :cover_image
      t.string :images, array: true, default: []

      t.timestamps

      # Indexes
      t.index :status
      t.index :price
      t.index :tags, using: "gin"
      t.index %i[latitude longitude]
      t.index :city
    end
  end
end
