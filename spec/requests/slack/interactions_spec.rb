require "rails_helper"

RSpec.describe "Interaction", type: :request do
  let!(:customer) { create(:customer, slack_team_id: JSON.parse(payload)["team"]["id"]) }
  let(:get_teams_resp) { double(success?: true) }
  before do
    allow_any_instance_of(Zenduty::Client).to receive(:get_teams).and_return(get_teams_resp)
  end
  subject { post "/slack/interactions", params: {"payload": payload} }
  let(:stub_refresh) { expect_any_instance_of(Slack::RefreshHome).to receive(:execute) }

  context "delete channel config" do
    let(:payload) { file_fixture("delete_channel_config.json").read }
    let(:id) { 15 }
    let!(:channel_config) { create(:channel_config, id: id) }

    it "delete records" do
      stub_refresh
      expect { subject }.to change { ChannelConfig.unscoped.find(15).disabled_at }.from nil
      expect(response).to have_http_status(:ok)
    end
  end

  context "submit zenduty token" do
    let(:payload) { file_fixture("zenduty_token.json").read }

    it "submit zenduty token" do
      stub_refresh
      expect { subject }.to change { ExternalAccount.count }.by 1
      expect(response).to have_http_status(:ok)
    end
  end

  context "submit invalid zenduty token" do
    let(:payload) { file_fixture("zenduty_token.json").read }
    let(:get_teams_resp) { double(success?: false, :[] => {}) }

    it "submit zenduty token" do
      stub_refresh
      expect { subject }.not_to change { ExternalAccount.count }
      expect(response).to have_http_status(:ok)
    end
  end

  context "select zenduty integration" do
    let(:payload) { file_fixture("integration_selection_zenduty.json").read }

    it "call slack" do
      expect_any_instance_of(Slack::Web::Client).to receive(:post).with('views.update', any_args)
      subject
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
      subject
      expect(response).to have_http_status(:ok)
    end

    context 'no options left' do
      let!(:external_account) { create(:external_account, customer: customer, platform: "zenduty") }

      it "call slack without options" do
        expect_any_instance_of(Slack::Web::Client).to receive(:post).with(
          'views.open',
          hash_including({view: /No more integrations available/})
        )
        subject
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
      subject
      expect(response).to have_http_status(:ok)
    end

    context 'select pagerduty' do
      let(:payload) { file_fixture("schedule_source_select-pd.json").read }

      let!(:external_account) { create(:external_account, customer: customer, platform: "zenduty") }
      let!(:other_external_account) { create(:external_account, customer: customer, platform: "pagerduty") }
      let(:schedules_resp) do
        {
          "schedules": [{ "id": "PZBWKR7", "summary": "customer"}]
        }
      end
      let(:stub_pd_schedules) { stub_request(:get, "https://api.pagerduty.com/schedules").to_return(status: 200, body: schedules_resp.to_json, headers: {}) }

      it "show zenduty schedules" do
        stub_pd_schedules
        expect_any_instance_of(Slack::Web::Client).to receive(:post).with(
          'views.update',
          anything
        )
        subject
        expect(response).to have_http_status(:ok)
      end
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
        subject
        expect(response).to have_http_status(:ok)
      end

      context "select team" do
        let(:get_schedule_resp) { [{name: "schedule 1", unique_id: "92ad792e-a1ec-46f7-8634-c0b738c0cf6e"}] }
        let(:payload) { file_fixture("schedule_source_select_team.json").read }
  
        it "submission" do
          allow_any_instance_of(Zenduty::Client).to receive(:get_teams).and_return get_teams_resp
          allow_any_instance_of(Zenduty::Client).to receive(:get_escalation_policies).and_return get_schedule_resp

          expect_any_instance_of(Slack::Web::Client).to receive(:post).with(
            'views.update',
            anything
          )
          subject
          expect(response).to have_http_status(:ok)
        end
      end

      context "select team without schedule" do
        let(:get_schedule_resp) { [] }
        let(:payload) { file_fixture("schedule_source_select_team.json").read }
  
        it "submission" do
          allow_any_instance_of(Zenduty::Client).to receive(:get_teams).and_return get_teams_resp
          allow_any_instance_of(Zenduty::Client).to receive(:get_escalation_policies).and_return get_schedule_resp

          expect_any_instance_of(Slack::Web::Client).not_to receive(:post).with(
            'views.update',
            anything
          )
          subject
          expect(response).to have_http_status(:ok)
          resp_body = JSON.parse(response.body)
          expect(resp_body).to include "errors"
        end
      end
    end
  end

  describe "submit channel config" do
    let(:payload) { file_fixture("create_channel_config.json").read }
    let!(:external_account) { create(:external_account, customer: customer, platform: "zenduty") }

    it "create config record" do
      stub_refresh
      expect { subject }.to change { ChannelConfig.count }.by 1
      expect(response).to have_http_status(:ok)
    end
  end
end