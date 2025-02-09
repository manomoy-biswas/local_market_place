class AddRefundFieldsToPayment < ActiveRecord::Migration[8.0]
  def change
    add_column :payments, :refund_id, :string
    add_column :payments, :refund_details, :jsonb, default: {}

    add_index :payments, :refund_id, unique: true
  end
end
