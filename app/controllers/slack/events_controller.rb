class Slack::EventsController < ApplicationController
  def create
    if params[:challenge].present?
      return render json: {challenge: params[:challenge]}
    end

    @slack_client = Slack::Web::Client.new

    case params[:event][:type]
    when 'app_home_opened'
      p params
      publish_hello
    when 'app_mention'
      send_message
    end
    
    head :ok
  end

  private

  def get_home
    external_accounts = customer.external_accounts
    if external_accounts.blank?
      @slack_client.views_publish(
        user_id: event[:user],
        view: {type: 'home', blocks: [{type: 'section', text: {type: 'mrkdwn', text: "Please link accounts"} }]}
      )
    else
      @slack_client.views_publish(
        user_id: event[:user],
        view: {type: 'home', blocks: [{type: 'section', text: {type: 'mrkdwn', text: "Here are the accounts"} }]}
      )
    end
    
  end

  def send_message
    @slack_client.chat_postMessage(channel: channel, text: 'Got it!', as_user: true)
  end

  def event
    params[:event]
  end

  def channel
    event[:channel]
  end

  def customer
    @customer ||= Customer.find_by(slack_team_id: params[:team_id])
  end
end
