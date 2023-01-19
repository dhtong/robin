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
    let!(:customer) { create(:customer, slack_team_id: payload["team_id"]) }
    let(:payload) { JSON.parse(file_fixture("app_mention.json").read) }

    it "store message" do
      stub_slack
      expect {
        post "/slack/events", params: payload
      }.to change { Message.count }.by 1      
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
        }.to_not change { Customer.count }
      end
    end
  end
end