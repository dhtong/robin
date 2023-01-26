class ChannelConfig < ApplicationRecord
  belongs_to :external_account
  default_scope { where(disabled_at: nil) }

  def oncall_users
    client = external_account.client 

    case external_account.platform
    when "pagerduty"
      client.get_oncall(escalation_policy_id)
    when "zenduty"
      escalation_policies = client.oncall(team_id)
      escalation_policy = escalation_policies.find{|policy| policy["escalation_policy"]["unique_id"] == escalation_policy_id}
      escalation_policy["users"].uniq {|user| user["username"]}
    end
  end
end
