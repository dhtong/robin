class Slack::CreateSupportCase < ApplicationJob
  queue_as :default

  def perform(event_id)
    Commands::CreateSupportCase.new.execute(event_id: event_id)
  end
end
