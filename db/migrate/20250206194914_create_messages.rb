class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :sender, null: false, foreign_key: { to_table: :users }
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :booking, foreign_key: true
      t.text :content, null: false
      t.datetime :read_at
      t.boolean :is_system_message, default: false
      t.string :message_type
      t.timestamps

      t.index :read_at
      t.index :message_type
      t.index %i[sender_id recipient_id]
    end
  end
end
