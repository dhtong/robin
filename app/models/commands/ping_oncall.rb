module Commands
  class PingOncall
    def initialize(message_id)
      @message = Records::Message.find(message_id)
      @customer = Records::Customer.find(@message.customer_id)
      @channel_config = Records::ChannelConfig.find_by(channel_id: @message.channel_id)
      @chat_client = Slack::Web::Client.new(token: @customer.slack_access_token)
    end

    def execute
      return post_message("there is no oncall schedule linked to this channel yet.") if @channel_config.blank?
      oncall_users = @channel_config.oncall_users

      slack_users = oncall_users.map do |user|
        begin
          resp = @chat_client.users_lookupByEmail(email: user["email"])
          resp["user"]["id"]
        rescue Slack::Web::Api::Errors::UsersNotFound
          post_message("Slack user not found for #{user["email"]}")
          nil
        end
      end.compact
      return if slack_users.empty?

      begin
        @chat_client.conversations_invite(channel: @message.channel_id, users: slack_users.join(","))
      rescue Slack::Web::Api::Errors::AlreadyInChannel, Slack::Web::Api::Errors::MissingScope
      end

      mentions = slack_users.map{|u| "<@#{u}>"}
      post_message("Hey someone needs you! #{mentions.join(', ')}")
    end

    private

    def post_message(msg)
      @chat_client.chat_postMessage(channel: @message.channel_id, thread_ts: @message.event_payload["thread_ts"], text: msg, as_user: true)
    end

    def ping_subscribers
      support_message_link = @chat_client.chat_getPermalink(channel: @message.channel_id, message_ts: @message.event_payload["ts"]))

      @channel_config.subscribers.each do |customer_user|
        @chat_client.chat_postMessage(channel: customer_user.slack_user_id, text: msg, as_user: true)
      end
    end
  end
end