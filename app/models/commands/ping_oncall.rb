module Commands
  class PingOncall
    def initialize(event_id)
      @event = Records::Event.includes(:message).find(event_id)
      @message = @event.message
      @customer = Records::Customer.find(@message.customer_id)
      @channel_config = Records::ChannelConfig.find_by(channel_id: @message.channel_id)
      @chat_client = Slack::Web::Client.new(token: @customer.slack_access_token)
      @user_repo = Repositories::Users.create
    end

    def execute
      return post_message("there is no oncall schedule linked to this channel yet.") if @channel_config.blank?
      oncall_users = @channel_config.oncall_users
      slack_users = oncall_users.map do |user|
        begin
          @user_repo.slack_id_by_email(email: user["email"], customer: @customer)
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

      ping_oncall(slack_users)
      # ping subscribers for app mention
      ping_slack_users(@channel_config.subscribers.map(&:slack_user_id)) if @event["type"] == 'app_mention'
    end

    private

    def post_message(msg)
      @chat_client.chat_postMessage(channel: @message.channel_id, thread_ts: @event["thread_ts"], text: msg, as_user: true)
    end

    def ping_oncall(slack_user_ids)
      case @event["type"]
      when 'message'
        # ping oncall uses privately if it's not app mention and not in a thread.
        ping_slack_users(slack_user_ids, "created a support case for " + @message.external_url) if @event.key?("thread_ts")
      when 'app_mention'
        mentions = slack_user_ids.map{|u| "<@#{u}>"}
        post_message("Hey someone needs you! #{mentions.join(', ')}")
      end
    end

    def ping_slack_users(slack_user_ids, message=nil)
      message ||= @message.external_url
      slack_user_ids.each do |slack_user_id|
        @chat_client.chat_postMessage(channel: slack_user_id, text: message, as_user: true)
      end
    end
  end
end