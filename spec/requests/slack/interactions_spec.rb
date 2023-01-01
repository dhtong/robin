require "rails_helper"

RSpec.describe "Interaction", type: :request do
  let(:payload) { file_fixture("zenduty_submission.json").read }
  let!(:customer) { create(:customer, slack_team_id: JSON.parse(payload)["team"]["id"]) }

  it "challenge" do
    expect {
      post "/slack/interactions", params: {"payload": payload}
    }.to change { ExternalAccount.count }.by 1
    expect(response).to have_http_status(:ok)
  end
end