require 'rails_helper'

RSpec.describe Commands::CreateSupportCase do
  let(:customer) { create(:customer) }
  let(:channel_id) { "TDFDS" }
  let(:slack_ts) { "1687797188.417309" }
  let(:message) { create(:message, customer: customer, channel_id: channel_id, slack_ts: slack_ts) }

  it 'create record' do
    expect { described_class.new.execute(message_id: message.id) }.to change { Records::SupportCase.count }
  end

  context 'support case exists' do
    let!(:current_case) { create(:support_case, channel_id: channel_id, slack_ts: slack_ts) }

    it 'does not create new' do
      expect { described_class.new.execute(message_id: message.id) }.not_to change { Records::SupportCase.count }
    end
  end

  context 'recent support case exists' do
    let(:other_ts) { "1787797188.417309" }
    let!(:current_case) { create(:support_case, channel_id: channel_id, slack_ts: other_ts) }

    it 'does not create new' do
      expect { described_class.new.execute(message_id: message.id) }.not_to change { Records::SupportCase.count }
    end
  end
end