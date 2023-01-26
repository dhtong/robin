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
    Message.create(content: params[:event][:text], customer: customer, channel_id: channel)
  end

  def send_message
    return @slack_client.chat_postMessage(channel: channel, thread_ts: params[:event][:ts], text: "there is no oncall schedule linked to this channel yet.", as_user: true) if channel_config.blank?
    oncall_users = channel_config.oncall_users
    p oncall_users
    slack_users = oncall_users.map do |user|
      begin
        resp = @slack_client.users_lookupByEmail(email: user["email"])
        resp["user"]["id"]
      rescue Slack::Web::Api::Errors::UsersNotFound
        @slack_client.chat_postMessage(channel: channel, thread_ts: params[:event][:thread_ts], text: "Slack user not found for #{user["email"]}", as_user: true)
      end
    end.compact
    p "slack uesr - ------- -- -- -- ----- #{slack_users}"
    return if slack_users.empty?

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
  
  def channel_config
    @channel_config ||= ChannelConfig.find_by(channel_id: channel)
  end

  def customer
    @customer ||= Customer.find_by(slack_team_id: params[:team_id])
  end
end
