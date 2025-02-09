class UpdateHostsForIndianBanking < ActiveRecord::Migration[8.0]
  def change
    # Add Indian-specific bank details to the jsonb column
    add_column :hosts, :bank_details, :jsonb, default: {}, null: false
  end
end
