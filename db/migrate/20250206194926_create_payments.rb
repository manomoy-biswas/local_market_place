class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :booking, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :commission_amount, precision: 10, scale: 2
      t.string :currency, default: "INR"
      t.integer :status, default: 0
      t.string :payment_method
      t.string :transaction_id
      t.string :gateway_reference
      t.jsonb :payment_details
      t.datetime :paid_at
      t.datetime :refunded_at
      t.string :refund_reason
      t.string :error_message

      t.timestamps

      t.index :transaction_id, unique: true
      t.index :gateway_reference
      t.index :status
      t.index :paid_at
    end
  end
end
