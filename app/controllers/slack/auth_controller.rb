class Slack::AuthController < ApplicationController
  def index
    client = Slack::Web::Client.new
    res = client.oauth_v2_access(client_id: ENV["SLACK_CLIENT_ID"], client_secret: ENV["SLACK_CLIENT_SECRET"], code: params[:code])
    puts res 
    ExternalAccount.create(customer: customer, token: res.access_token)

    head :ok
  end

  private

  def customer
    @customer ||= Customer.find_or_create_by(slack_team_id: params[:team_id][:id])
  end
end
