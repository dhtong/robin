require 'rails_helper'

RSpec.describe Records::ChannelConfig do
  let(:customer_users) { create_list(:customer_user, 3) }
  let(:channel_conf) { create(:channel_config) }
  
  it 'create subscriber assocations' do
    expect { channel_conf.subscribers << customer_users }.to change { Records::ChannelSubscriber.count }.by 3
  end
end
