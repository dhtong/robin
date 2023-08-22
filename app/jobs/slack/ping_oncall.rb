class Slack::PingOncall < ApplicationJob
  queue_as :default

  def perform(event_id, ping_type)
    command = Commands::PingOncall.new(event_id, ping_type)
    command.execute
  end
end
