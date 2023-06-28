class Slack::EventsController < ApplicationController
  def create
    if params[:challenge].present?
      return render json: {challenge: params[:challenge]}
    end

    @slack_client = Slack::Web::Client.new(token: customer.slack_access_token)

    case params[:event][:type]
    when 'app_home_opened'
      Slack::RefreshHome.new(customer_id: customer.id, caller_id: params[:event][:user]).execute
    when 'app_mention'
      msg = record_message
      return head :ok if msg.nil?
      Slack::PingOncall.perform_later(msg.id)
      Slack::CreateSupportCase.perform_later(msg.id)
    end
    
    head :ok
  end

  private

  def record_message
    external_message_id = params[:event][:client_msg_id]
    existing_message = Records::Message.find_by(external_id: external_message_id) if external_message_id.present?
    return nil if existing_message.present?

    cu = Commands::FindOrCreateUser.new.execute(slack_user_id: params[:event][:user], slack_team_id: params[:event][:user_team] || params[:event][:team], referer_customer_id: customer.id)
    Records::Message.create(
      content: params[:event][:text],
      customer: customer,
      channel_id: channel,
      event_payload: params[:event],
      external_id: external_message_id,
      slack_ts: params[:event][:thread_ts] || params[:event][:ts],
      customer_user: cu
    )
  end

  def channel
    params[:event][:channel]
  end
  
  def channel_config
    @channel_config ||= Records::ChannelConfig.find_by(channel_id: channel)
  end

  def customer
    @customer ||= Records::Customer.find_by(slack_team_id: params[:team_id])
  end
end
