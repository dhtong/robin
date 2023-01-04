class Slack::EventsController < ApplicationController
  def create
    if params[:challenge].present?
      return render json: {challenge: params[:challenge]}
    end

    @slack_client = Slack::Web::Client.new

    case params[:event][:type]
    when 'app_home_opened'
      Slack::RefreshHome.new(customer, @slack_client, params[:event][:user]).execute
    when 'app_mention'
      # send_message
    end
    
    head :ok
  end

  private

  # def send_message
  #   @slack_client.chat_postMessage(channel: channel, text: 'Got it!', as_user: true)
  # end

  # def channel
  #   event[:channel]
  # end

  def customer
    @customer ||= Customer.find_or_create_by(slack_team_id: params[:team_id])
  end
end
