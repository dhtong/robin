class PopulateCustomerUserData < ApplicationJob
  queue_as :default

  def perform(customer_user_id, referer_customer_id=nil)
    command = Commands::PopulateCustomerUserData.new
    command.execute(customer_user_id: customer_user_id, referer_customer_id: referer_customer_id)
  end
end
