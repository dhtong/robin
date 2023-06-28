require 'rails_helper'

RSpec.describe Commands::FindOrCreateUser do
  include ActiveJob::TestHelper

  after do
    clear_enqueued_jobs
  end 

  let(:referer) { create(:customer) }
  let(:c) { create(:customer) }
  let(:customer_user) { create(:customer_user, customer: c) }

  let(:stub_slack) do
    stub_request(:post, "https://slack.com/api/users.info").
      with(headers: { Authorization: "Bearer #{referer.slack_access_token}"}).
      to_return(status: 200, body: {ok: true, user: { profile: {email: "a@gmail.com"} }}.to_json, headers: {})
  end

  let(:slack_user_id) { Faker::Crypto.md5 }
  let(:slack_team_id) { Faker::Crypto.md5 }
  let(:referer_customer_id) { Faker::Crypto.md5 }

  subject { described_class.new.execute(slack_user_id: slack_user_id, slack_team_id: slack_team_id, referer_customer_id: referer_customer_id) }

  it 'create records' do
    expect { subject }.to change { Records::CustomerUser.count }.by(1).
      and change { Records::Customer.count }.by 1
  end

  it 'enqueue job' do
    expect { subject }.to have_enqueued_job(PopulateCustomerUserData)
  end

  it 'return customer user' do
    res = subject
    expect(res).to be_a Records::CustomerUser 
  end

  context 'user alread exists' do
    let(:customer) { create(:customer, slack_team_id: slack_team_id) }
    let!(:existing) { create(:customer_user, customer: customer, slack_user_id: slack_user_id) }

    it 'does not create customer user' do
      expect { subject }.not_to change { Records::CustomerUser.count }
    end

    it 'does not create customer' do
      expect { subject }.not_to change { Records::Customer.count }
    end

    it 'does not enqueue job' do
      expect { subject }.not_to have_enqueued_job(PopulateCustomerUserData)
    end
  end
end