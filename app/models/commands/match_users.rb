module Commands
  # match_users
  # 1) loads users from an oncall resource/policy.
  # 2) loads users from slack
  # 3) attempts to match oncall users with slack user 
  # 4) creates relevant cutomer_users, user_contacts and user_contact_associations records
  # 5) user_contact_associations are only active if user email match.
  # this command is called when a channel is setup. where we preload all users into our system.
  class MatchUsers
    def initialize(external_account_id)
      @external_account_id = external_account_id
    end

    def execute
      oncall_users = external_account.list_oncall_users
      slack_users = get_slack_users
      oncall_users.each do |ou|
        slack_users.each do |su|
          score = su.match?(ou)
          next if score <= 0
          upsert_records(su, ou)
          # find a match. go to next oncall user
          break
        end
      end
    end

    private

    def upsert_records(slack_user, oncall_user)
      # TODO maybe link oncall user id as well
      customer_user = Records::CustomerUser.find_or_create_by(slack_user_id: slack_user.id, customer_id: external_account.customer_id)
      status = slack_user.email == oncall_user.email ? "active" : "pending"
      upsert_contact(oncall_user.email, customer_user.id, status)
      # TODO not collecting slack user email for now.
    end

    def upsert_contact(email, customer_user_id, status)
      contact = Records::UserContact.find_or_create_by(number: email, method: "email")
      Records::UserContactAssociation.upsert({user_contact_id: contact.id, customer_user_id: customer_user_id, status: status}, unique_by: [:user_contact_id, :customer_user_id])
    end

    def get_slack_users
      slack_resp = customer.slack_client.users_list
      slack_resp["members"].map { |m| Domain::User.from_slack(m) }
    end

    def external_account
      @external_account ||= Records::ExternalAccount.find(@external_account_id)
    end

    def customer
      @customer ||= external_account.customer
    end
  end
end