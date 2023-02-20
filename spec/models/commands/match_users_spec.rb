require 'rails_helper'

RSpec.describe Commands::MatchUsers do
  let(:customer) { create(:customer) }
  describe "#execute" do
    let(:external_account) { create(:external_account, platform: :zenduty, customer: customer) }
    let(:oncall_email) { "maryjane@sharklasers.com" } 
    let(:zd_resp) do
      [
        {
          "unique_id": "1f1b4d79-ed32-44fc-926d-f794b975200c",
          "name": "Operation Team",
          "account": "0713dc12-40b0-46ff-b0f9-c6b126399277",
          "creation_date": "2022-07-08",
          "members": [
            {
              "unique_id": "90a97f10-d290-4bd0-9f83-525f130c6399",
              "team": "1f1b4d79-ed32-44fc-926d-f794b975200c",
              "user": {
                "username": "216bba3d-7268-4a8e-89e9-6",
                "first_name": "Anshul",
                "last_name": "Rajput",
                "email": "anshulrajput229@gmail.com"
              },
              "joining_date": "2022-07-08T10:29:36.408864Z",
              "role": 1
            },
            {
              "unique_id": "4af52265-b69e-4cd0-948a-fba33933588d",
              "team": "1f1b4d79-ed32-44fc-926d-f794b975200c",
              "user": {
                "username": "507dfda0-a1fd-40e5-943a-e",
                "first_name": "Mary",
                "last_name": "Jane",
                "email": oncall_email
              },
              "joining_date": "2022-07-08T10:31:56.849950Z",
              "role": 2
            },
            {
              "unique_id": "76e76d20-2c82-49be-b987-244c8c6af57b",
              "team": "1f1b4d79-ed32-44fc-926d-f794b975200c",
              "user": {
                "username": "85b563c8-18d0-4668-9462-9",
                "first_name": "Vishwa",
                "last_name": "Krishnakumar",
                "email": "vishwa@yellowant.com"
              },
              "joining_date": "2022-07-08T10:32:42.213487Z",
              "role": 2
            }
          ],
          "owner": "216bba3d-7268-4a8e-89e9-6",
          "roles": [
            {
              "unique_id": "ce2e4fec-7fb9-440c-b400-9a33639d8ba3",
              "team": "1f1b4d79-ed32-44fc-926d-f794b975200c",
              "title": "Incident Commander",
              "description": "The incident commander is the person responsible for all aspects of the incident response, including quickly developing incident objectives, managing all incident operations, application of resources as well as responsibility for all persons involved. The incident commander sets priorities and defines the organization of the incident response teams and the overall incident action plan.",
              "creation_date": "2022-07-08T10:29:36.431801Z",
              "rank": 1
            }
          ]
        },
        {
          "unique_id": "61010821-08aa-4098-94f8-f88f1990b54a",
          "name": "Production Team",
          "account": "0713dc12-40b0-46ff-b0f9-c6b126399277",
          "creation_date": "2022-07-08",
          "members": [
            {
              "unique_id": "d916157c-ff8b-43be-8e99-4b63699fdf72",
              "team": "61010821-08aa-4098-94f8-f88f1990b54a",
              "user": {
                "username": "216bba3d-7268-4a8e-89e9-6",
                "first_name": "Anshul",
                "last_name": "Rajput",
                "email": "anshulrajput229@gmail.com"
              },
              "joining_date": "2022-07-08T10:41:36.600148Z",
              "role": 1
            }
          ],
          "owner": "216bba3d-7268-4a8e-89e9-6",
          "roles": [
            {
              "unique_id": "89752b4a-43df-401d-9dc0-a446690a7a0e",
              "team": "61010821-08aa-4098-94f8-f88f1990b54a",
              "title": "Incident Commander",
              "description": "The incident commander is the person responsible for all aspects of the incident response, including quickly developing incident objectives, managing all incident operations, application of resources as well as responsibility for all persons involved. The incident commander sets priorities and defines the organization of the incident response teams and the overall incident action plan.",
              "creation_date": "2022-07-08T10:41:36.623257Z",
              "rank": 1
            }
          ]
        }
      ]
    end

    let!(:stub_zd) do
      stub_request(:get, "https://www.zenduty.com/api/account/teams/").
        to_return(status: 200, body: zd_resp.to_json, headers: {'Content-Type'=>'application/json'})
    end
    let(:slack_email) { "glenda@south.oz.coven" }
    let(:slack_user_id) { "W07QCRPA4" }
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
                "id": slack_user_id,
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

    subject { described_class.new(external_account.id).execute }

    it "create user contact" do
      expect { subject }.to change { Records::UserContact.count }.by 1
      r = Records::UserContact.all
      expect(r.pluck(:number)).to match_array([oncall_email])

      expect(Records::UserContactAssociation.all.pluck(:status)).to match_array(["pending"])
    end

    it "create cutomer user" do
      expect { subject }.to change { Records::CustomerUser.count }.by 1
      r = Records::CustomerUser.last
      expect(r.customer_id).to eq customer.id
      expect(r.slack_user_id).to eq slack_user_id
    end

    context "contact exists but belong to a different customer_user" do
      let(:other_customer_user) { create(:customer_user) }
      let!(:user_contact) { create(:user_contact, method: :email, number: oncall_email, customer_users: [other_customer_user]) }

      it "create custmer_user_id" do
        expect { 
          subject
        }.to change { Records::CustomerUser.count }.by 1

        customer_users = user_contact.reload.customer_users
        expect(customer_users.length).to be 2
        expect(customer_users.pluck(:id)).to include Records::CustomerUser.last.id
      end

      it "no change to other" do
        expect { subject }.not_to change { other_customer_user.reload.user_contacts.count }
      end
    end

    context "contact exists and belong to correct customer_user" do
      let!(:customer_user) { create(:customer_user, customer: customer, slack_user_id: slack_user_id) }
      let!(:user_contact) { create(:user_contact, method: :email, number: oncall_email, customer_users: [customer_user]) }

      it "noop" do
        expect { subject }.not_to change { Records::CustomerUser.count }
      end
    end

    context "a user with email match" do
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
                  "id": slack_user_id,
                  "profile": {
                      "first_name": "Mary",
                      "last_name": "Jane",
                      "email": "glenda@south.oz.coven"
                  }
              },
              {
                "id": "W67DDRPB",
                "profile": {
                    "email": "anshulrajput229@gmail.com"
                }
              }
          ]
        }
      end

      it "create two users" do
        expect { subject }.to change { Records::CustomerUser.count }.by 2
      end

      it "create three contacts" do
        expect { subject }.to change { Records::UserContact.count }.by 2
      end

      it "one of the association is active" do
        subject
        expect(Records::UserContactAssociation.all.pluck(:status)).to match_array ["active", "pending"]
      end
    end
  end
end
