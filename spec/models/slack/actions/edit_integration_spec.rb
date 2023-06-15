require 'rails_helper'

RSpec.describe Slack::Actions::EditIntegration do
  let!(:external_account) { create(:external_account, customer: customer, platform: 'pagerduty') }
  let(:customer) { create(:customer) }
  let(:inter) do Domain::Slack::Interaction.new(
    {
      view: {id: 'dd', state: { values: {} }, callback_id: 'callback'},
      actions: [{type: '', block_id: 'pagerduty_integration-block', action_id: 'edit_integration_action', selected_option: { value: 'delete' }}],
      user: { id: 'dd' }
    }
  )
  end
  let(:cconfig) { create(:channel_config, external_account: external_account) }
  let(:past_disabled_at) { 10.minute.ago }
  let(:disabled_config) { create(:channel_config, external_account: external_account, disabled_at: past_disabled_at) }

  let(:refresh_cmd) { double(new: double(execute: nil)) }
  
  it 'disable every thing' do
    expect { described_class.new(refresh_cmd).execute(customer, inter, nil) }
    .to change { external_account.reload.disabled_at }.from(nil)
    .and change { cconfig.reload.disabled_at }.from(nil)
  end

  it 'not set disabled_at for already disabled' do
    expect { described_class.new(refresh_cmd).execute(customer, inter, nil) }.not_to change { disabled_config.reload.disabled_at }.from past_disabled_at
  end
end
