class Pagerduty::AuthController < ApplicationController
  def index
    pd_client = Pagerduty::Client.new(ENV["PD_CLIENT_ID"], ENV["PD_CLIENT_SECRET"])
    # not handling response failure TODO
    resp = pd_client.oauth(params[:code]).body
    p resp
    ExternalAccount.create(customer: customer, platform: "pagerduty", token: resp["access_token"], refresh_token: resp["refresh_token"])
    redirect_to "https://supportbots.xyz/", allow_other_host: true
  end

  private

  def customer
    @customer ||= Customer.find_by(external_id: params[:external_id])
  end
end
