class CreateHosts < ActiveRecord::Migration[8.0]
  def change
    create_table :hosts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :business_name
      t.string :tax_number
      t.string :business_address
      t.string :business_phone
      t.string :website
      t.string :bank_account_number
      t.string :bank_routing_number
      t.string :bank_name
      t.string :identity_proof
      t.string :address_proof
      t.decimal :commission_rate, precision: 5, scale: 2, default: 10.0
      t.datetime :verified_at
      t.integer :status, default: 0
      t.jsonb :verification_details, default: {}

      t.timestamps

      t.index :business_name
      t.index :status
      t.index :verified_at
    end
  end
end
