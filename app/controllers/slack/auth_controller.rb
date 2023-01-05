class Slack::AuthController < ApplicationController
  def index
    client = Slack::Web::Client.new
    res = client.oauth_v2_access(client_id: ENV["SLACK_CLIENT_ID"], client_secret: ENV["SLACK_CLIENT_SECRET"], code: params[:code])
    head :ok
  end
end
