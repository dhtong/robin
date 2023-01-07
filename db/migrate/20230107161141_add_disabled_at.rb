class AddDisabledAt < ActiveRecord::Migration[7.0]
  def change
    add_column :channel_configs, :disabled_at, :datetime
    add_column :external_accounts, :disabled_at, :datetime
  end
end
