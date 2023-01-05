class AddSlackTokensToCustomers < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :slack_access_token, :string
  end
end
