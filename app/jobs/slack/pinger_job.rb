class Slack::PingerJob < ApplicationJob
  queue_as :default

  def perform(*args)
    token = Records::Customer.find(1).slack_access_token
    slack_client = Slack::Web::Client.new(token: token)
    slack_client.chat_postMessage(channel: 'C04LGGHFMDL', text: "job test #{args}", as_user: true)
  end
end
