class AddCustomerExternalId < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto'
    add_column :customers, :external_id, :uuid, default: "gen_random_uuid()"
    add_index :customers, :external_id
  end
end
