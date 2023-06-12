module Slack::Actions
  class SelectEscalationPolicyTeam
    include Slack::ChannelConfigBlocks

    def initialize
    end

    def execute(customer, interaction, payload)
      action = interaction.actions[0]
      selected_team_id = action.selected_option.value
      selected_platform = interaction.view.state[PLATFORM_BLOCK_ID][PLATFORM_ACTION_ID]["selected_option"]["value"]

      selected_account = customer.external_accounts.where(platform: selected_platform).first
      presenter = Presenters::Slack::ZendutyChannelConfig.from_blocks(payload["view"]["blocks"])

      available_escalation_policies = selected_account.client.get_escalation_policies(selected_team_id)
      # TODO this validation is not show right now. maybe validate teams before showing team options.
      return Slack::ValidationError.new(ZENDUTY_TEAM_BLOCK_ID, "No escalation policies available") if available_escalation_policies.blank?
      presenter.with_escalation_policies(available_escalation_policies)

      Slack::Web::Client.new(token: customer.slack_access_token).views_update(view_id: interaction.view.id, view: presenter.present)
    end
  end
end