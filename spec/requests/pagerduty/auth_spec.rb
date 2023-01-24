require "rails_helper"

RSpec.describe "Pagerduty::Auth", type: :request do
  let(:oauth_resp) do
    {
      "client_info":"prefix_legacy_app",
      "id_token":"eyJraWQiOiIxNzg3MzQ1MDA4IiwieDV0IjoiX2Nxbk1aWlBBcEF0V3kyVm11T1Y4dUc5VHNvIiwiYWxnIjoiUlMyNTYifQ.eyJleHAiOjE2NjYxOTk2MDEsIm5iZiI6M",
      "token_type":"bearer",
      "access_token":"pdus+_0XBPWQQ_b2b2060b-e7af-44a1-8ddf-9c56fedd8d4f",
      "refresh_token":"pdus+_1XBPWQQ_f85dd2f1-b906-478a-a9e6-678952529e4e",
      "scope":"openid write",
      "expires_in":864000
    }
  end

  let(:stub_pd) { stub_request(:post, "https://identity.pagerduty.com/oauth/token").to_return(status: 200, body: oauth_resp.to_json, headers: {}) }
  let(:external_id) { "ddd-eee" }

  it "auth" do
    stub_pd
    get "/pagerduty/auth", params: { external_id: external_id }
    expect(response).to redirect_to("https://supportbots.xyz/")
  end
end