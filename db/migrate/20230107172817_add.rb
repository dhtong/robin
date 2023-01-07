class Add < ActiveRecord::Migration[7.0]
  def change
    add_index :channel_configs, [:external_account_id, :channel_id], unique: true
  end
end
