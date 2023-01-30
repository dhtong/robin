class AddPayloadToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :event_payload, :jsonb, default: {}
  end
end
