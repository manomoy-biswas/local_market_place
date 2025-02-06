class AddSearchIndexesToExperiences < ActiveRecord::Migration[8.0]
  def up
    execute "CREATE INDEX experiences_text_search ON experiences USING gin(to_tsvector("english", title || " " || description))"
  end

  def down
    remove_index :experiences, name: "experiences_text_search"
  end
end
