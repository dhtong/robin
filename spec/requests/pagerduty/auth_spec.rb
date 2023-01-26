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

  let(:oauth_url) { "https://identity.pagerduty.com/oauth/token" }
  let(:stub_pd) { stub_request(:post, oauth_url).to_return(status: 200, body: oauth_resp.to_json, headers: {}) }
  let!(:customer) { create(:customer) }
  let(:external_id) { customer.external_id }
  subject { get "/pagerduty/auth", params: { external_id: external_id} }
  let!(:customer) { create(:customer) }

  it "auth" do
    stub_pd
    expect { subject }.to change { Records::ExternalAccount.count }.by 1
    expect(response).to redirect_to("https://supportbots.xyz/")
  end

  context "failed" do
    let(:oauth_resp) { { "error": "invalid_grant" } }
    let(:stub_pd) { stub_request(:post, oauth_url).to_return(status: 400, body: oauth_resp.to_json, headers: {}) }

    it "400" do
      stub_pd
      expect { subject }.not_to change { Records::ExternalAccount.count }
      expect(response).to have_http_status(:bad_request)
    end
  end
end