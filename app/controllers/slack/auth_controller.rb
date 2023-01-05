class Slack::AuthController < ApplicationController
  def index
    client = Slack::Web::Client.new
    res = client.oauth_v2_access(client_id: ENV["SLACK_CLIENT_ID"], client_secret: ENV["SLACK_CLIENT_SECRET"], code: params[:code])
    customer = Customer.find_or_create_by(slack_team_id: res.team&.id, platform: "slack")
    ExternalAccount.create(customer: customer, token: res.access_token)
    head :ok
  end
end
