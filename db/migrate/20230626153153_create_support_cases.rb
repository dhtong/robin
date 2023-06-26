class CreateSupportCases < ActiveRecord::Migration[7.0]
  def change
    create_table :support_cases do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :channel_id, index: true
      t.string :slack_ts, index: true
      t.string :instigator_message_id
      t.timestamps
      t.index :created_at
    end
  end
end
