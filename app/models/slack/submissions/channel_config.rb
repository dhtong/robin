module Slack
  module Submissions
    class ChannelConfig
      include ChannelConfigBlocks

      def initialize
      end

      def execute(customer, interaction, _payload)
        state_values = interaction.view.state.dig("values")
        channel_id = state_values[CHANNEL_SELECT_BLOCK_ID]["conversations_select-action"]["selected_conversation"]
        escalation_policy_id = state_values[ESCALATION_POLICY_BLOCK_ID][ESCALATION_POLICY_ACTION_ID]["selected_option"]["value"]
        escalation_policy_platform = state_values[PLATFORM_BLOCK_ID][PLATFORM_ACTION_ID]["selected_option"]["value"]

        team_id = state_values[ZENDUTY_TEAM_BLOCK_ID][ZENDUTY_TEAM_ACTION_ID]["selected_option"]["value"] if escalation_policy_platform == "zenduty"

        selected_account_id = customer.external_accounts.where(platform: escalation_policy_platform).pluck(:id).first
        attributes = {chat_platform: "slack", team_id: team_id, escalation_policy_id: escalation_policy_id, external_account_id: selected_account_id, channel_id: channel_id}
        # a channel can only link to one escalation_policy. this also deletes the history if the user has set a different policy before.
        channel_config = Records::ChannelConfig.unscoped.find_or_initialize_by(channel_id: channel_id, external_account_id: selected_account_id)
        channel_config.update!(chat_platform: "slack", team_id: team_id, escalation_policy_id: escalation_policy_id, disabled_at: nil)
        # channel_config = Records::ChannelConfig.upsert(attributes, unique_by: [:external_account_id, :channel_id])
        subscriber_slack_ids = state_values.dig(SUBSCRIBER_BLOCK_ID, SUBSCRIBER_ACTION_ID, "selected_users")
        subscribers = subscriber_slack_ids&.map do |s_id|
          Records::CustomerUser.find_or_create_by!(customer_id: customer.id, slack_user_id: s_id)
        end || []
        channel_config.subscribers = subscribers
      end
    end
  end
end