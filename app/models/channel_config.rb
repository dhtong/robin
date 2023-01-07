class ChannelConfig < ApplicationRecord
  belongs_to :external_account
  default_scope { where(disabled_at: nil) }
end
