class Slack::EventsController < ApplicationController
  def create
    if params[:challenge].present?
      return render json: {challenge: params[:challenge]}
    end

    @slack_client = Slack::Web::Client.new(token: customer.slack_access_token)

    case params[:event][:type]
    when 'app_home_opened'
      Slack::RefreshHome.new(customer_id: customer.id, caller_id: params[:event][:user]).execute
    when 'app_mention', 'message'
      event = record_event
      return head :ok if event.nil?
      Slack::PingOncall.perform_later(event.id)
      Slack::CreateSupportCase.perform_later(event.id)
    end
    
    head :ok
  end

  private

  def record_event
    # skip bot message events
    return if params[:event].key?(:bot_id)
    external_event_id = params[:event_id]
    external_event = Records::Event.find_by(external_id: external_event_id) if external_event_id.present?
    return if external_event.present?
    ActiveRecord::Base.transaction do
      event = Records::Event.create(
        external_id: external_event_id,
        event: params[:event],
        platform: :slack
      )
      msg = record_message
      event.update(message: msg)
      event
    end
  end

  def record_message
    # skip duplicates and bot messages
    external_message_id = params[:event][:client_msg_id]
    existing_message = Records::Message.find_by(external_id: external_message_id)
    # always process app_mention for now, even though we might reprocess it.
    # for a same message, we could get two events 
    return existing_message if existing_message.present?

    cu = Commands::FindOrCreateUser.new.execute(slack_user_id: params[:event][:user], slack_team_id: params[:event][:user_team] || params[:event][:team], referer_customer_id: customer.id)
    url = @slack_client.chat_getPermalink(channel: channel, message_ts: params[:event][:ts])[:permalink]
    Records::Message.create(
      content: params[:event][:text],
      customer: customer,
      channel_id: channel,
      event_payload: params[:event],
      external_id: external_message_id,
      # prefer parent thread
      slack_ts: params[:event][:thread_ts] || params[:event][:ts],
      customer_user: cu,
      external_url: url
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
