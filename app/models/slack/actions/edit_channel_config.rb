module Slack::Actions
  class EditChannelConfig

    def initialize
      @refresh_home_cmd_clz = ::Slack::RefreshHome
      @new_channel_cfg_action = NewChannelConfig.new
    end

    def execute(customer, interaction, _payload)
      action = interaction.actions[0]

      case action.selected_option.value
      when "delete"
        channel_config_id = action.block_id.scan(/^\d+/).first.to_i
        Records::ChannelConfig.where(id: channel_config_id).update_all(disabled_at: Time.current)
        @refresh_home_cmd_clz.new(
          customer_id: customer.id,
          caller_id: interaction.user.id
        ).execute
      when "edit"
        @new_channel_cfg_action.execute(customer, interaction, nil)
      end
    end
  end
end