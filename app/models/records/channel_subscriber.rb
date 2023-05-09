module Records
  class ChannelSubscriber < ApplicationRecord
    belongs_to :customer_user
    belongs_to :channel_config
  end
end
