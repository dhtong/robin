module Presenters::Slack
  class ShowChannelConfig
    def present(channel_config)
      @channel_config = channel_config
      [slack_channel_id, connection_info, subscribers].join("\n")
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
      "subscribers: #{users.join(',')}"
    end
  end
end
