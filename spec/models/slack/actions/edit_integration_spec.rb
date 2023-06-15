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

  let(:refresh_cmd) { double(new: double(execute: nil)) }
  
  it 'create subscriber assocations' do
    expect { described_class.new(refresh_cmd).execute(customer, inter, nil) }.to change { external_account.reload.disabled_at }.from nil
  end
end
