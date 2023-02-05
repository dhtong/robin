module Commands
  class MatchZendutyUser

    def execute(channel_config_id, oncall_user_id)
      channel_config = Records::ChannelConfig.find(channel_config_id)
      oncall_user = get_oncall_user(channel_config, oncall_user_id)
      contact = Records::UserContact.find_by(number: oncall_user.email, method: "email")
      return if contact.present?

      # find prospects. match by name. and partial email matching.
      customer = channel_config.external_account.customer
      slack_client = Slack::Web::Client.new(token: customer.slack_access_token)
      slack_client.users.list
    end

    private

    def get_oncall_user(channel_config, oncall_user_id)
      oncall_client = channel_config.external_account.client
      case channel_config.chat_platform
      when "zenduty"
        oncall_client.get_user(channel_config.team_id, oncall_user_id)
      when "pagerduty"
        oncall_client.get_user(oncall_user_id)
      end
    end
  end
end