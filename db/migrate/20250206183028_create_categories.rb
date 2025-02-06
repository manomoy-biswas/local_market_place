class CreateCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.string :icon
      t.string :image
      t.integer :status, default: 0
      t.integer :position
      t.integer :experiences_count, default: 0

      t.timestamps

      t.index :slug, unique: true
      t.index :status
      t.index :position
    end
  end
end
