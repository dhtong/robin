module Slack::Actions
  class EditChannelConfig

    def initialize
      @refresh_home_cmd_clz = ::Slack::RefreshHome
    end

    def execute(customer, interaction, _payload)
      action = interaction.actions[0]

      case action.selected_option.value
      when "delete"
        channel_config_id = action.block_id.scan(/^\d+/).first.to_i
        Records::ChannelConfig.where(id: channel_config_id).update_all(disabled_at: Time.current)
      end
      @refresh_home_cmd_clz.new(
        customer,
        Slack::Web::Client.new(token: customer.slack_access_token),
        interaction.user.id
      ).execute
    end
  end
end