class CreateChannelConfigs < ActiveRecord::Migration[7.0]
  def change
    create_table :channel_configs do |t|
      t.string :chat_platform
      t.string :channel_id
      t.string :schedule_platform
      t.string :schedule_id

      t.timestamps
    end
  end
end
