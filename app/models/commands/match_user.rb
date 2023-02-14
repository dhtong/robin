module Commands
  class MatchUser
    # given an oncall user info in an external platform find a corresponding slack user
    # the slack user should be in the same team/customer of the oncall user
    def execute(external_account_id, oncall_user_id, channel_config_id: nil)
      # get domain oncall user
      external_account = Records::ExternalAccount.find(external_account_id)
      oncall_user = get_oncall_user(external_account, oncall_user_id, channel_config_id)
      contact = Records::UserContact.find_by(number: oncall_user.email, method: "email")
      contact&.customer_users&.each do |cu|
        return if cu.customer_id == external_account.customer_id
      end
      # if customer_user does not belong to the same customer as the external_account. we will switch the contact to a different customer user

      # find prospects. match by name. and partial email matching.
      slack_users = get_slack_users(external_account)
      slack_user = slack_users.find { |su| su.match?(oncall_user) }
      # don't find any matched ones
      return if slack_user.nil?

      customer_user = Records::CustomerUser.find_or_create_by(slack_user_id: slack_user.id, customer_id: external_account.customer_id)
      contact = Records::UserContact.find_or_create_by(number: oncall_user.email, method: "email")
      contact.update(customer_users: [customer_user])
    end

    private

    def get_oncall_user(external_account, oncall_user_id, channel_config_id)
      oncall_client = external_account.client
      case external_account.platform
      when "zenduty"
        channel_config = Records::ChannelConfig.find(channel_config_id)
        oncall_client.get_user(channel_config.team_id, oncall_user_id)
      when "pagerduty"
        oncall_client.get_user(oncall_user_id)
      end
    end

    def get_slack_users(external_account)
      customer = external_account.customer
      slack_client = Slack::Web::Client.new(token: customer.slack_access_token)
      res = slack_client.users_list
      res["members"].map do |m|
        Domain::User.from_slack(m)
      end
    end
  end
end