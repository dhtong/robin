module Slack
  module Submissions
    class ZendutyToken
      include ChannelConfigBlocks

      def initialize
        @match_users_for_account_job = Slack::MatchUsersForAccount
      end

      def execute(customer, interaction, _payload)
        zenduty_token = interaction.view.state.dig("values", ZENDUTY_TOKEN_BLOCK_ID, "zenduty_token-action", "value")
        return if zenduty_token.nil?
        # TODO prevent duplicates.
        account = Records::ExternalAccount.new(customer: customer, platform: "zenduty", token: zenduty_token)
        # TODO find a cheaper endpoint
        res = account.client.get_teams
        return ValidationError.new(ZENDUTY_TOKEN_BLOCK_ID, res["error"]) unless res.success?
        account.save!
        @match_users_for_account_job.perform_later(account.id)
      end
    end
  end
end