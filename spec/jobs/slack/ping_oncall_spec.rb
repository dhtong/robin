require 'rails_helper'

RSpec.describe Slack::PingOncall, type: :job do
  include ActiveJob::TestHelper
  
  describe "#perform_later" do
    let(:customer) { create(:customer) }
    let(:external_account) { create(:external_account, platform: :zenduty, customer: customer) }
    let!(:channel_config) { create(:channel_config, external_account: external_account, team_id: "team", escalation_policy_id: escalation_policy_id) }
    let!(:message) { create(:message, channel_id: channel_config.channel_id, customer: customer) }
    let(:event) { create(:event, message: message) }
    let(:oncall_email) { "maryjane@sharklasers.com" }
    let(:escalation_policy_id) { "ddd" }
    let(:contact) { create(:user_contact, method: :email, number: email) }
    let!(:user) { create(:customer_user, user_contacts: [contact], slack_user_id: slack_user_id, customer: customer) }
    let(:slack_user_id) { 'cccc' }
    let!(:stub_slack_invite) do
      stub_request(:post, "https://slack.com/api/conversations.invite").
         to_return(status: 200, body: "", headers: {})
    end

    let(:email) { Faker::Internet.email }
    let(:zd_resp) do
      [
        {
          "escalation_policy": {
            "unique_id": escalation_policy_id
          },
          "users": [
            {
              "username": "216bba3d-7268-4a8e-89e9-6",
              "email": email
            }
          ]
        }
      ]
    end
    let!(:stub_zd) do
      stub_request(:get, "https://www.zenduty.com/api/account/teams/team/oncall").
        to_return(status: 200, body: zd_resp.to_json, headers: {'Content-Type'=>'application/json'})
    end
    # let!(:stub_slack) { stub_request(:post, /slack/).to_return(status: 200, body: "", headers: {}) }

    subject { described_class.perform_later(event.id) }

    it "uploads a backup" do
      perform_enqueued_jobs { subject }
    end
  end
end
