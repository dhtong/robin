require 'rails_helper'

RSpec.describe Commands::PopulateCustomerUserData do
  let(:referer) { create(:customer) }
  let(:c) { create(:customer) }
  let(:customer_user) { create(:customer_user, customer: c) }

  let(:stub_slack) do
    stub_request(:post, "https://slack.com/api/users.info").
      with(headers: { Authorization: "Bearer #{referer.slack_access_token}"}).
      to_return(status: 200, body: {ok: true, user: { profile: {email: "a@gmail.com"} }}.to_json, headers: {})
  end

  subject { described_class.new.execute(customer_user_id: customer_user.id, referer_customer_id: referer.id) }

  it 'use referer record' do
    stub_slack
    subject
  end

  it 'create contacts' do
    stub_slack
    expect { subject }.to change { Records::UserContact.count }.by 1
  end
end