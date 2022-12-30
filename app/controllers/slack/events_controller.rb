class Slack::EventsController < ApplicationController
  def create
    if params[:challenge].present?
      render json: {challenge: params[:challenge]}
      return
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
    # external_accounts = 
  end

  def publish_hello
    @slack_client.views_publish(user_id: event[:user], view: {type: 'home', blocks: [{type: 'section', text: {type: 'mrkdwn', text: "hello #{DateTime.now}"} }]})
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
end
