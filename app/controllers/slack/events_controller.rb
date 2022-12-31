class Slack::EventsController < ApplicationController
  def create
    if params[:challenge].present?
      return render json: {challenge: params[:challenge]}
    end

    @slack_client = Slack::Web::Client.new

    case params[:event][:type]
    when 'app_home_opened'
      p params
      get_home
    when 'app_mention'
      send_message
    end
    
    head :ok
  end

  private

  def get_home
    external_accounts = customer.external_accounts
    blocks = []
    if external_accounts.any?
      blocks << {type: 'section', text: {type: 'mrkdwn', text: "Here are the accounts"} }
      # todo show accounts
    end

    blocks << integration_dropdown

    p "pushing blocks ----- " + blocks
    @slack_client.views_publish(
      user_id: event[:user],
      view: {type: 'home', blocks: blocks}
    )
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

  def integration_dropdown
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "Pick a tool to integrate with"
      },
      "accessory": {
        "action_id": "integration",
        "type": "static_select",
        "placeholder": {
          "type": "plain_text",
          "text": "Select a tool",
          "emoji": true
        },
        "options": [
          {
            "text": {
              "type": "plain_text",
              "text": "Pagerduty",
              "emoji": true
            },
            "value": "pagerduty"
          },
          {
            "text": {
              "type": "plain_text",
              "text": "Zenduty",
              "emoji": true
            },
            "value": "zenduty"
          },
        ],
      }
    }
  end
end
