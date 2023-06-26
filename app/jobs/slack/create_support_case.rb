class Slack::CreateSupportCase < ApplicationJob
  queue_as :default

  def perform(message_id)
    Commands::CreateSupportCase.new.execute(message_id: message_id)
  end
end
