class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :reviewable, polymorphic: true
      t.integer :rating, null: false
      t.text :content
      t.boolean :verified, default: false
      t.datetime :verified_at
      t.timestamps

      t.index :rating
      t.index :verified
    end
  end
end
