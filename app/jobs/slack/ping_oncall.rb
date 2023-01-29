class Slack::PingOncall < ApplicationJob
  queue_as :default

  def perform(message_id)
    load_context(message_id)
    send_message
  end

  private

  def load_context(message_id)
    @message = Records::Message.find(message_id)
    @customer = Records::Customer.find(message.customer_id)
    @channel_config = Records::ChannelConfig.find_by(channel_id: message.channel_id)
    @slack_client = Slack::Web::Client.new(token: customer.slack_access_token)
  end

  def send_message
    # TODO need to add thread_ts: params[:event][:ts]
    return @slack_client.chat_postMessage(channel: @message.channel_id, text: "there is no oncall schedule linked to this channel yet.", as_user: true) if channel_config.blank?
    oncall_users = @channel_config.oncall_users

    slack_users = oncall_users.map do |user|
      begin
        resp = @slack_client.users_lookupByEmail(email: user["email"])
        resp["user"]["id"]
      rescue Slack::Web::Api::Errors::UsersNotFound
        @slack_client.chat_postMessage(channel: channel, text: "Slack user not found for #{user["email"]}", as_user: true)
        nil
      end
    end.compact
    return if slack_users.empty?

    begin
      @slack_client.conversations_invite(channel: @message.channel_id, users: slack_users.join(","))
    rescue Slack::Web::Api::Errors::AlreadyInChannel, Slack::Web::Api::Errors::MissingScope
    end

    mentions = slack_users.map{|u| "<@#{u}>"}

    @slack_client.chat_postMessage(channel: @message.channel_id, text: "Hey someone needs you! #{mentions.join(', ')}", as_user: true)
  end
end
