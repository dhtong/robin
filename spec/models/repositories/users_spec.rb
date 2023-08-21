require 'rails_helper'

RSpec.describe Repositories::Users do
  let(:client) { double }

  subject { described_class.new(slack_client_clz: client) }
  
  let(:email) { Faker::Internet.email }
  let(:contact) { create(:user_contact, method: :email, number: email) }
  let(:slack_user_id) { 'ddd' }
  let!(:user) { create(:customer_user, user_contacts: [contact], slack_user_id: slack_user_id) }

  it 'returns result' do
    expect(subject.slack_id_by_email(email: email, customer: user.customer)).to eq slack_user_id
  end

  it 'use db' do
    expect(client).not_to receive(:new)
    subject.slack_id_by_email(email: email, customer: user.customer)
  end

  context 'belongs to different customers' do
    let(:other_slack_user) { 'other' }
    let!(:user2) { create(:customer_user, user_contacts: [contact], slack_user_id: other_slack_user) }

    it 'return correct customer user' do
      expect(subject.slack_id_by_email(email: email, customer: user2.customer)).to eq other_slack_user
    end
  end

  context 'not found in db' do
    let(:query_email) { Faker::Internet.email }
    let(:client) { Slack::Web::Client }
    let(:slack_return_id) { "ddddd" }
    let!(:stub_slack) do
      stub_request(:post, "https://slack.com/api/users.lookupByEmail").
        to_return(status: 200, body: {ok: true, user: {id: slack_return_id}}.to_json, headers: {})
    end

    it 'use client' do
      expect(client).to receive(:new).and_call_original
      res = subject.slack_id_by_email(email: query_email, customer: user.customer)
      expect(res).to eq slack_return_id
    end
  end
end