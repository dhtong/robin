class Slack::PingOncall < ApplicationJob
  queue_as :default

  def perform(event_id)
    command = Commands::PingOncall.new(event_id)
    command.execute
  end
end
