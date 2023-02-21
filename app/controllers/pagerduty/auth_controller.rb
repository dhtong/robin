class Pagerduty::AuthController < ApplicationController
  def index
    pd_client = Pagerduty::OauthClient.new(ENV["PD_CLIENT_ID"], ENV["PD_CLIENT_SECRET"])
    resp = pd_client.oauth(params[:code], params[:external_id])
    return render json: resp.body, status: :bad_request unless resp.success?

    resp_body = JSON.parse(resp.body)
    # TODO prevent duplicate
    account = Records::ExternalAccount.create!(customer: customer, platform: "pagerduty", token: resp_body["access_token"], refresh_token: resp_body["refresh_token"])
    Slack::MatchUsersForAccount.perform_later(account.id)
    redirect_to "https://supportbots.xyz/", allow_other_host: true
  end

  private

  def customer
    @customer ||= Records::Customer.find_by(external_id: params[:external_id])
  end
end
