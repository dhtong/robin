class Slack::EventsController < ApplicationController
  def create
    if params[:challenge].present?
      return render json: {challenge: params[:challenge]}
    end

    @slack_client = Slack::Web::Client.new(token: customer.external_accounts.slack.pluck(:token).first)

    case params[:event][:type]
    when 'app_home_opened'
      Slack::RefreshHome.new(customer, @slack_client, params[:event][:user]).execute
    when 'app_mention'
      send_message
    end
    
    head :ok
  end

  private

  def send_message
    oncall_users = channel_configs.flat_map do |channel_config|
      escalation_policies = channel_config.external_account.client.oncall(channel_config.team_id)
      escalation_policy = escalation_policies.find{|policy| policy["escalation_policy"]["unique_id"] == channel_config.escalation_policy_id}
      escalation_policy["users"]
    end.uniq_by{|user| user["username"]}
    names = oncall_users.map{|user| "#{user['first_name']} #{user['last_name']} (#{user['email']})}"}

    @slack_client.chat_postMessage(channel: channel, text: "TODO: ping #{names.join(', ')}", as_user: true)
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
