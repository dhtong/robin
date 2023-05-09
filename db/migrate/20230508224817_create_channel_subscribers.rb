class CreateChannelSubscribers < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_subscribers do |t|
      t.references :customer_user, null: false
      t.references :channel_config, null: false
      t.datetime :disabled_at
      t.timestamps
    end
  end
end
