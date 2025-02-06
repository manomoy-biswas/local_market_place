class AddRatingColumnsToExperiences < ActiveRecord::Migration[8.0]
  def change
    add_column :experiences, :average_rating, :decimal, precision: 3, scale: 2, default: 0.0
    add_column :experiences, :total_reviews_count, :integer, default: 0
    add_index :experiences, :average_rating
  end
end
