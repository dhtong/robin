module Commands
  class PopulateCustomerUserData

    # set referer_customer_id when we don't have a direct relationship with customer_user_id
    # this happens in shared channels
    def execute(customer_user_id:, referer_customer_id: nil)
      customer_user = Records::CustomerUser.find(customer_user_id)

      slack_client = referer_customer_id.present? ? Records::Customer.find(referer_customer_id).slack_client : customer_user.customer.slack_client
      # todo use #users_profile_get if we have the scope
      slack_user_info = slack_client.users_info(user: customer_user.slack_user_id)
      upsert_contact(slack_user_info.dig("user", "profile", "email"), customer_user.id, "active")
    end
  
    private
  
    def upsert_contact(email, customer_user_id, status)
      return if email.blank?
      contact = Records::UserContact.find_or_create_by(number: email, method: "email")
      Records::UserContactAssociation.upsert({user_contact_id: contact.id, customer_user_id: customer_user_id, status: status}, unique_by: [:user_contact_id, :customer_user_id])
    end
  end
end