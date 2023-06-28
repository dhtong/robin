module Commands
  class FindOrCreateUser
    # create minimum customer and customer user info first.
    # kick off a worker to fill other info async.
    # if referer is set, user referer slack token since new slack team id might be missing
    def execute(slack_user_id:, slack_team_id:, referer_customer_id: nil)
      return if slack_user_id.nil? || slack_team_id.nil?
      c = Records::Customer.find_or_create_by(slack_team_id: slack_team_id)
      cu = Records::CustomerUser.find_or_initialize_by(slack_user_id: slack_user_id, customer: c)
      ::PopulateCustomerUserData.perform_later(cu.id, referer_customer_id) if cu.new_record?
      cu.save!
      cu
    end
  end
end