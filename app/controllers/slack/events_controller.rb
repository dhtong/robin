class Slack::EventsController < ApplicationController
  def create
    if params[:challenge].present?
      return render json: {challenge: params[:challenge]}
    end

    @slack_client = Slack::Web::Client.new(token: customer.external_accounts.slack.first)

    case params[:event][:type]
    when 'app_home_opened'
      Slack::RefreshHome.new(customer, @slack_client, params[:event][:user]).execute
    when 'app_mention'
      # send_message
    end
    
    head :ok
  end

  private

  def send_message
    client = Zenduty
    channel_configs.each do |channel_config|
      oncall = channel_config.external_account.client.oncall(channel_config.team_id)
    end

    @slack_client.chat_postMessage(channel: channel, text: 'TODO: page oncalls for #{}', as_user: true)
  end

  def channel
    event[:channel]
  end
  
  def team_ids
    channel_configs.map(&:team_id).compact.uniq
  end

  def channel_configs
    @channel_configs ||= ChannelConfig.where(channel_id: channel)
  end

  def customer
    @customer ||= Customer.find_by(slack_team_id: params[:team_id])
  end
end
