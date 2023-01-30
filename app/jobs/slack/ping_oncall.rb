class Slack::PingOncall < ApplicationJob
  queue_as :default

  def perform(message_id)
    command = Commands::PingOncall.new(message_id)
    command.execute
  end
end
