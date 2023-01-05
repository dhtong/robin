class AddTeamIdToChannelConfigs < ActiveRecord::Migration[7.0]
  def change
    add_column :channel_configs, :team_id, :string
  end
end
