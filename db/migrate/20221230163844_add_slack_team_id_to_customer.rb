class AddSlackTeamIdToCustomer < ActiveRecord::Migration[7.0]
  def change
    add_column :customers, :slack_team_id, :string
    add_index :customers, :slack_team_id
  end
end
