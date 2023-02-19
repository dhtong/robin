class Slack::AuthController < ApplicationController
  def index
    client = Slack::Web::Client.new
    res = client.oauth_v2_access(client_id: ENV["SLACK_CLIENT_ID"], client_secret: ENV["SLACK_CLIENT_SECRET"], code: params[:code])
    customer = Records::Customer.find_or_create_by(slack_team_id: res.team&.id)
    installer = Records::CustomerUser.find_or_create_by(customer_id: customer.id, slack_user_id: res.authed_user.id)
    customer.update(slack_access_token: res.access_token, installer_customer_user_id: installer.id)
    redirect_to "https://supportbots.xyz/", allow_other_host: true
  end
end
