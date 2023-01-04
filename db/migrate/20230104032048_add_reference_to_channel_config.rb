class AddReferenceToChannelConfig < ActiveRecord::Migration[7.0]
  def change
    remove_column :channel_configs, :schedule_platform
    add_reference :channel_configs, :external_account, index: true
  end
end
