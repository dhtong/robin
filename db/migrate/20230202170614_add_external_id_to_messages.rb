class AddExternalIdToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :external_id, :string
    add_index :messages, :external_id
  end
end
