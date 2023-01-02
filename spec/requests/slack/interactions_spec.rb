require "rails_helper"

RSpec.describe "Interaction", type: :request do
  let!(:customer) { create(:customer, slack_team_id: JSON.parse(payload)["team"]["id"]) }

  context "submit zenduty token" do
    let(:payload) { file_fixture("zenduty_token.json").read }

    it "submit zenduty token" do
      expect {
        post "/slack/interactions", params: {"payload": payload}
      }.to change { ExternalAccount.count }.by 1
      expect(response).to have_http_status(:ok)
    end
  end

  context "select zenduty integration" do
    let(:payload) { file_fixture("integration_selection_zenduty.json").read }

    it "call slack" do
      expect_any_instance_of(Slack::Web::Client).to receive(:post).with('views.open', any_args)
      post "/slack/interactions", params: {"payload": payload}
      expect(response).to have_http_status(:ok)
    end
  end
end