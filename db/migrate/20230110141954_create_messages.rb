class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.text :content
      t.string :channel_id
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
    add_index :messages, :channel_id
  end
end
