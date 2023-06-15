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
        ActiveRecord::Base.transaction do
          accounts = Records::ExternalAccount.where(customer: customer, platform: integration_name)
          Records::ChannelConfig.where(external_account: accounts, disabled_at: nil).update_all(disabled_at: Time.now.utc)
          accounts.update_all(disabled_at: Time.now.utc)
        end
      end

      @refresh_home_cmd_clz.new(
        customer,
        Slack::Web::Client.new(token: customer.slack_access_token),
        interaction.user.id
      ).execute
    end
  end
end