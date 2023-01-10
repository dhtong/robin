class Slack::EventsController < ApplicationController
  def create
    if params[:challenge].present?
      return render json: {challenge: params[:challenge]}
    end

    @slack_client = Slack::Web::Client.new(token: customer.slack_access_token)

    case params[:event][:type]
    when 'app_home_opened'
      Slack::RefreshHome.new(customer, @slack_client, params[:event][:user]).execute
    when 'app_mention'
      record_message
      send_message
    end
    
    head :ok
  end

  private

  def record_message
    # removing the first word in text
    content = params[:event][:text][/(?<=\s).*/]
    return if content.nil?
    Message.create(content: content, customer: customer, channel_id: channel)
  end

  def send_message
    return @slack_client.chat_postMessage(channel: channel, thread_ts: params[:event][:ts], text: "there is no oncall schedule linked to this channel yet.", as_user: true) if channel_configs.blank?

    oncall_users = channel_configs.flat_map do |channel_config|
      escalation_policies = channel_config.external_account.client.oncall(channel_config.team_id)
      escalation_policy = escalation_policies.find{|policy| policy["escalation_policy"]["unique_id"] == channel_config.escalation_policy_id}
      escalation_policy["users"]
    end.uniq {|user| user["username"]}

    slack_users = oncall_users.map do |zenduty_user|
      resp = @slack_client.users_lookupByEmail(email: zenduty_user["email"])
      resp["user"]["id"]
    end

    begin
      @slack_client.conversations_invite(channel: channel, users: slack_users.join(","))
    rescue Slack::Web::Api::Errors::AlreadyInChannel, Slack::Web::Api::Errors::MissingScope
    end

    mentions = slack_users.map{|u| "<@#{u}>"}

    @slack_client.chat_postMessage(channel: channel, thread_ts: params[:event][:thread_ts], text: "Someone needs you! #{mentions.join(', ')}", as_user: true)
  end

  def channel
    params[:event][:channel]
  end
  
  def channel_configs
    @channel_configs ||= ChannelConfig.where(channel_id: channel)
  end

  def customer
    @customer ||= Customer.find_by(slack_team_id: params[:team_id])
  end
end
