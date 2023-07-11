require "rails_helper"

RSpec.describe "Event", type: :request do
  let(:stub_slack) { stub_request(:post, /slack/).to_return(status: 200, body: "", headers: {}) }

  it "challenge" do
    challenge_message = 'sss'
    post "/slack/events", params: { challenge: challenge_message }

    response_body = JSON.parse(response.body)
    expect(response_body['challenge']).to eq challenge_message
    expect(response).to have_http_status(:ok)
  end

  context "app_mention" do
    let!(:stub_slack_permalink) do
      stub_request(:post, "https://slack.com/api/chat.getPermalink").to_return(status: 200, body: {ok: true, permalink: "https://ss.com"}.to_json, headers: {})
    end
    let!(:customer) { create(:customer, slack_team_id: payload["team_id"]) }
    let(:payload) { JSON.parse(file_fixture("app_mention.json").read) }
    let!(:channel_config) { create(:channel_config, channel_id: payload["event"]["channel"]) }

    it "store message" do
      expect {
        post "/slack/events", params: payload
      }.to change { Records::Message.count }.by 1

      # call again should not create another message
      expect {
        post "/slack/events", params: payload
      }.not_to change { Records::Message.count }
    end

    it 'message has customer user' do
      post "/slack/events", params: payload
      expect(Records::Message.last.customer_user_id).to be_present
    end

    context 'no message id' do
      let!(:exisiting_message) { create(:message, external_id: nil) }
      before do
        payload["event"]["client_msg_id"] = nil
      end

      it 'create a new message' do
        expect {
          post "/slack/events", params: payload
        }.to change { Records::Message.count }
      end
    end

    it "create ping job " do
      expect {
        post "/slack/events", params: payload
      }.to have_enqueued_job(Slack::PingOncall)

      # call again should not create the job
      expect {
        post "/slack/events", params: payload
      }.not_to have_enqueued_job(Slack::PingOncall)
    end

    it "create support job " do
      expect {
        post "/slack/events", params: payload
      }.to have_enqueued_job(Slack::CreateSupportCase)
    end
  end

  context "home" do
    let!(:customer) { create(:customer, slack_team_id: payload["team_id"]) }
    let(:payload) { JSON.parse(file_fixture("app_home_opened.json").read) }

    it "first view" do
      expect_any_instance_of(Slack::Web::Client).to receive(:views_publish)
      post "/slack/events", params: payload
      expect(response).to have_http_status(:ok)
    end

    context "viewed already" do
      let!(:existing_customer) { create(:customer, slack_team_id: payload["team_id"]) }

      it "view" do
        allow_any_instance_of(Slack::Web::Client).to receive(:views_publish)
        expect {
          post "/slack/events", params: payload
        }.to_not change { Records::Customer.count }
      end
    end
  end
end