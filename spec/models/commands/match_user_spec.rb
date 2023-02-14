require 'rails_helper'

RSpec.describe Commands::MatchUser do
  let(:customer) { create(:customer) }
  describe "#execute" do
    let(:external_account) { create(:external_account, platform: :zenduty, customer: customer) }
    let(:channel_config) { create(:channel_config, chat_platform: :zenduty, external_account: external_account, team_id: "team") }
    let(:oncall_user_id) { 2 }
    let(:oncall_email) { "maryjane@sharklasers.com" }
    let(:zd_resp) do
      {
        "unique_id": "828e4a7b-bb12-4ffc-baa5-7681634d4f7f",
        "team": "61010821-08aa-4098-94f8-f88f1990b54a",
        "user": {
          "username": "507dfda0-a1fd-40e5-943a-e",
          "first_name": "Mary",
          "last_name": "Jane",
          "email": oncall_email
        },
        "joining_date": "2022-07-08T11:09:38.230395Z",
        "role": 2
      }
    end
    let!(:stub_zd) do
      stub_request(:get, "https://www.zenduty.com/api/account/teams/team/members/#{oncall_user_id}").
        to_return(status: 200, body: zd_resp.to_json, headers: {'Content-Type'=>'application/json'})
    end
    let(:slack_resp) do
      {
        "ok": true,
        "members": [
            {
                "id": "W012A3CDE",
                "profile": {
                    "email": "spengler@ghostbusters.example.com",
                }
            },
            {
                "id": "W07QCRPA4",
                "profile": {
                    "first_name": "Mary",
                    "last_name": "Jane",
                    "email": "glenda@south.oz.coven"
                }
            }
        ]
    }
    end
    let!(:stub_slack) do
      stub_request(:post, "https://slack.com/api/users.list").
         to_return(status: 200, body: slack_resp.to_json, headers: {'Content-Type'=>'application/json'})
    end


    it "create user contact" do
      expect { 
        described_class.new.execute(external_account.id, oncall_user_id, channel_config_id: channel_config.id)
      }.to change { Records::UserContact.count }.by 1
      r = Records::UserContact.last
      expect(r.number).to eq oncall_email
      expect(r.method).to eq "email"
    end

    it "create cutomer user" do
      expect { 
        described_class.new.execute(external_account.id, oncall_user_id, channel_config_id: channel_config.id)
      }.to change { Records::CustomerUser.count }.by 1
      r = Records::CustomerUser.last
      expect(r.customer_id).to eq customer.id
      expect(r.slack_user_id).to eq "W07QCRPA4"
    end

    context "contact exists but belong to a different customer_user" do
      let!(:user_contact) { create(:user_contact, method: :email, number: oncall_email) }

      it "change custmer_user_id" do
        expect { 
          described_class.new.execute(external_account.id, oncall_user_id, channel_config_id: channel_config.id)
        }.to change { Records::CustomerUser.count }.by 1

        expect(user_contact.reload.customer_users.pluck(:id)).to eq [Records::CustomerUser.last.id]
      end
    end

    context "contact exists and belong to correct customer_user" do
      let(:customer_user) { create(:customer_user, customer: customer) }
      let!(:user_contact) { create(:user_contact, method: :email, number: oncall_email, customer_users: [customer_user]) }

      it "noop" do
        expect { 
          described_class.new.execute(external_account.id, oncall_user_id, channel_config_id: channel_config.id)
        }.not_to change { Records::CustomerUser.count }
      end
    end
  end
end
