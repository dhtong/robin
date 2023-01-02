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
      expect_any_instance_of(Slack::Web::Client).to receive(:post).with('views.update', any_args)
      post "/slack/interactions", params: {"payload": payload}
      expect(response).to have_http_status(:ok)
    end
  end

  describe "add integration" do
    let(:payload) { file_fixture("add_integration.json").read }

    it "call slack with options" do
      expect_any_instance_of(Slack::Web::Client).to receive(:post).with(
        'views.open',
        hash_including({view: /options/})
      )
      post "/slack/interactions", params: {"payload": payload}
      expect(response).to have_http_status(:ok)
    end

    context 'no options left' do
      let!(:external_account) { create(:external_account, customer: customer, platform: "zenduty") }

      it "call slack without options" do
        expect_any_instance_of(Slack::Web::Client).to receive(:post).with(
          'views.open',
          hash_including({view: /No more integrations available/})
        )
        post "/slack/interactions", params: {"payload": payload}
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "new channel config" do
    let(:payload) { file_fixture("new_channel_config.json").read }

    it "call slack to open view" do
      expect_any_instance_of(Slack::Web::Client).to receive(:post).with(
        'views.open',
        anything
      )
      post "/slack/interactions", params: {"payload": payload}
      expect(response).to have_http_status(:ok)
    end

    context 'select zenduty' do
      let(:payload) { file_fixture("schedule_source_select.json").read }
      let!(:external_account) { create(:external_account, customer: customer, platform: "zenduty") }
      let!(:other_external_account) { create(:external_account, customer: customer, platform: "pagerduty") }
      let(:get_teams_resp) { [{unique_id: "47975507-d54d-42d5-8d31-622653bd2360", name: "Operations Team"}] }

      it "show zenduty schedules" do
        allow_any_instance_of(Zenduty::Client).to receive(:get_teams).and_return get_teams_resp
        
        expect_any_instance_of(Slack::Web::Client).to receive(:post).with(
          'views.update',
          anything
        )
        post "/slack/interactions", params: {"payload": payload}
        expect(response).to have_http_status(:ok)
      end
    end
  end
end