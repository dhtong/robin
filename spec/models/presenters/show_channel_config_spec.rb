require 'rails_helper'

RSpec.describe Presenters::Slack::ShowChannelConfig do
  let(:external_account) { double(platform: "zenduty") }
  let(:escalation_policy_id) { "dafd-2efs" }
  let(:subscriber) { double(slack_user_id: "123") }
  let(:subscribers) { [subscriber] }
  let(:slack_channel_id) { "SDFRHYS" }
  let(:channel_config) do
    double(
      external_account: external_account,
      escalation_policy_id: escalation_policy_id,
      subscribers: subscribers,
      channel_id: slack_channel_id
    )
  end
  
  it 'display' do
    j = described_class.new.present(channel_config)
    expect(j).to eq "<##{slack_channel_id}>"
  end

  it 'display context' do
    j = described_class.new.present_context(channel_config)
    expect(j).to eq "platform: Zenduty, policy id: #{escalation_policy_id}\nsubscribers: <@123>"
  end

  context "no subscribers" do
    let(:subscribers) { [] }

    it 'display without subscribers' do
      j = described_class.new.present_context(channel_config)
      expect(j).to eq "platform: Zenduty, policy id: #{escalation_policy_id}"
    end
  end
end
