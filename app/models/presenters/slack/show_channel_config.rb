module Presenters::Slack
  class ShowChannelConfig
    def present(channel_config)
      @channel_config = channel_config
      slack_channel_id
    end

    def present_context(channel_config)
      @channel_config = channel_config
      [connection_info, subscribers].compact.join("\n")
    end

    private

    def slack_channel_id
      "<##{@channel_config.channel_id}>"
    end

    def connection_info
      "platform: #{@channel_config.external_account.platform.capitalize}, policy id: #{@channel_config.escalation_policy_id}"
    end

    def subscribers
      users = @channel_config.subscribers.map{|u| "<@#{u.slack_user_id}>"}
      return "subscribers: #{users.join(',')}" if users.any?
      return
    end
  end
end
