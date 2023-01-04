class SwitchFromScheduleToEscalationPolicy < ActiveRecord::Migration[7.0]
  def change
    remove_column :channel_configs, :schedule_id
    add_column :channel_configs, :escalation_policy_id, :string
  end
end
