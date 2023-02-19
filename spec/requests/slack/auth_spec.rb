require "rails_helper"

RSpec.describe "Slack::Auth", type: :request do
  let(:code) { 'code' }
  let(:auth_resp) do
    {
      "ok": true,
      "access_token": "xoxb-17653672481-19874698323-pdFZKVeTuE8sk7oOcBrzbqgy",
      "token_type": "bot",
      "scope": "commands,incoming-webhook",
      "bot_user_id": "U0KRQLJ9H",
      "app_id": "A0KRD7HC3",
      "team": {
          "name": "Slack Softball Team",
          "id": "T9TK3CUKW"
      },
      "enterprise": {
          "name": "slack-sports",
          "id": "E12345678"
      },
      "authed_user": {
          "id": "U1234",
          "scope": "chat:write",
          "access_token": "xoxp-1234",
          "token_type": "user"
      }
    }
  end
  let!(:stub_auth) do
    stub_request(:post, "https://slack.com/api/oauth.v2.access").
    to_return(status: 200, body: auth_resp.to_json, headers: {})
  end

  subject { get "/slack/auth", params: { code: code } }

  it "redirect" do
    subject
    expect(response).to have_http_status(302)
  end

  it "create customer" do
    expect { subject }.to change { Records::Customer.count }.by 1
  end

  it "create customer_user" do
    expect { subject }.to change { Records::CustomerUser.count }.by 1
  end

  context "already exists" do
    let!(:customer) { create(:customer, slack_team_id: auth_resp[:team][:id]) }

    it "does not create another" do
      expect { subject }.not_to change { Records::Customer.count }
      expect(response).to have_http_status(302)
    end
  end
end