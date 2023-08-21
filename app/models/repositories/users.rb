module Repositories
  class Users
    def initialize(slack_client_clz:)
      @slack_client = slack_client_clz
    end

    def self.create
      new(slack_client_clz: Slack::Web::Client)
    end

    def slack_id_by_email(email:, customer:)
      cu = Records::CustomerUser.joins(:user_contacts).where(
        user_contacts: {number: email, method: :email},
        customer_id: customer.id)
      return cu.first.slack_user_id if cu.any?
      @slack_client.new(token: customer.slack_access_token).users_lookupByEmail(email: email).dig("user", "id")
    end
  end
end