require 'rails_helper'

RSpec.describe Commands::StartSupportCaseReview do
  let(:customer) { create(:customer) }
  let(:channel_id) { "TDFDS" }
  let(:slack_ts) { "1687797188.417309" }
  let(:message) { create(:message, customer: customer, channel_id: channel_id, slack_ts: slack_ts) }
  let!(:support_case) { create(:support_case, instigator_message: message) }

  subject { described_class.new.execute(case_id: support_case.id) }

  let!(:stub_slack_permalink) do
    stub_request(:post, "https://slack.com/api/chat.getPermalink").to_return(status: 200, body: {ok: true, permalink: "https://ss.com"}.to_json, headers: {})
  end

  let!(:stub_slack_post_message) do
    stub_request(:post, "https://slack.com/api/chat.postMessage").to_return(status: 200, body: "", headers: {})
  end

  it 'create record' do
    expect { subject }.to change { Records::SupportCaseReview.count }.by 1
  end

  context 'review exists' do
    let!(:review) { create(:support_case_review, support_case: support_case) }

    it 'does not create record' do
      expect { subject }.not_to change { Records::SupportCaseReview.count }
    end
  end

  context 'internal case' do
    let(:internal_user) { create(:customer_user, customer: customer) }
    let(:message) { create(:message, customer: customer, channel_id: channel_id, slack_ts: slack_ts, customer_user: internal_user) }

    it 'does not create record' do
      expect { subject }.not_to change { Records::SupportCaseReview.count }
    end
  end
end