class Slack::MatchUsersForAccount < ApplicationJob
  queue_as :default

  def perform(external_account_id)
    Commands::MatchUsers.new(external_account_id).execute
  end
end
