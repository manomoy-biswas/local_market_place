class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      # Authentication fields
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      # User type and status
      t.integer :role, default: 0
      t.integer :status, default: 0

      # Verification
      t.string :verification_token
      t.datetime :verification_sent_at
      t.datetime :verified_at

      # OAuth fields
      t.string :provider
      t.string :uid

      # Timestamps
      t.timestamps

      # Indexes
      t.index :email, unique: true
      t.index :reset_password_token, unique: true
      t.index :verification_token, unique: true
      t.index %i[provider uid], unique: true
    end
  end
end
