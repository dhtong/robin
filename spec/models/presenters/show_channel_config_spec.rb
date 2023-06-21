require 'rails_helper'

RSpec.describe Presenters::Slack::ShowChannelConfig do
  let(:external_account) { double(platform: "zenduty") }
  let(:escalation_policy_id) { "dafd-2efs" }
  let(:subscriber) { double(slack_user_id: "123") }
  let(:slack_channel_id) { "SDFRHYS" }
  let(:channel_config) do
    double(
      external_account: external_account,
      escalation_policy_id: escalation_policy_id,
      subscribers: [subscriber],
      channel_id: slack_channel_id
    )
  end
  
  it 'display' do
    j = described_class.new.present(channel_config)
    expect(j).to eq "<##{slack_channel_id}>\nplatform: Zenduty, policy id: #{escalation_policy_id}\nsubscribers: <@123>"
  end
end
