class AddLinkToMessages < ActiveRecord::Migration[7.0]
  def change
    add_column :messages, :external_url, :string
  end
end
