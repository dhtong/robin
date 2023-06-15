module Slack::Actions
  class EditIntegration
    def self.create
      new(::Slack::RefreshHome)
    end

    def initialize(refresh_home_cmd_clz)
      @refresh_home_cmd_clz = refresh_home_cmd_clz
    end

    def execute(customer, interaction, _payload)
      action = interaction.actions[0]

      case action.selected_option.value
      when "delete"
        integration_name = action.block_id.partition("_integration-block")[0]
        Records::ExternalAccount.where(customer: customer, platform: integration_name).update_all(disabled_at: Time.now.utc)
      end

      @refresh_home_cmd_clz.new(
        customer,
        Slack::Web::Client.new(token: customer.slack_access_token),
        interaction.user.id
      ).execute
    end
  end
end